use std::collections::HashMap;
use std::sync::Arc;

use async_trait::async_trait;
use auth_jwt::structs::{ADMINISTRATOR_ROLE, AccessTokenPayload, CUSTOMER_ROLE, FOREMAN_ROLE, INSPECTOR_ROLE};
use axum::response::IntoResponse;
use axum::{Json, http::StatusCode, response::Response};
use orm::prelude::*;
use schema::prelude::*;
use shared::prelude::*;
use uuid::Uuid;

use crate::AppState;
use crate::entities::*;

#[async_trait]
pub trait IProjectService: Send + Sync {
    async fn get_project(&self, r: GetProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn get_inspector_projects(&self, r: GetProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn create_project(
        &self,
        r: CreateProjectRequest,
        t: AccessTokenPayload,
    ) -> Result<Response, AppErr>;

    async fn commit_project(&self, r: ProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn activate_project(&self, r: ProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;

    async fn set_project_foreman(&self, r: SetProjectForemanRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn get_project_statuses(&self) -> Result<Response,AppErr>;

    async fn get_project_inspectors(&self, r: GetProjectInspectorsRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct ProjectService {
    state: AppState,
}

#[async_trait]
impl IProjectService for ProjectService {
    async fn get_inspector_projects(&self, r: GetProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let (offset, limit) = r.pagination.map(|p| (p.offset, p.limit)).unwrap_or((0, 0));
        let total: i64 = sqlx::query_as::<_, (i64,)>("
            SELECT COUNT(*) FROM project.project p 
            inner join project.iko_relationship ir on ir.project = p.uuid 
            WHERE ir.user_uuid = $1
            GROUP by p.created_at
            ORDER BY p.created_at DESC
        ")
            .bind(&t.uuid)
            .fetch_one(self.state.orm().get_executor())
            .await
            .into_app_err()?
            .0;
        let rows = sqlx::query_as::<_, RowProjectWithAttachment>("
            WITH proj_page AS (
                SELECT 
                p.*,
                uf.fcs AS foreman,
                ao.name AS created_by
                FROM project.project p
                LEFT JOIN auth.users uf
                    ON uf.uuid = p.foreman
                left join auth.orgs ao
                    on ao.uuid = p.created_by
                inner join project.iko_relationship ir on ir.project = p.uuid AND ir.user_uuid = $3
                WHERE p.address like $4
                ORDER BY p.created_at DESC
                OFFSET $1 LIMIT $2
            )
            SELECT pp.*,
                a.uuid AS attachment_uuid,
                a.original_filename,
                a.base_entity_uuid,
                a.content_type
            FROM proj_page pp
            LEFT JOIN attachment.attachments a 
                ON a.base_entity_uuid = pp.uuid;
        ")
            .bind(&offset)
            .bind(&limit)
            .bind(&t.uuid)
            .bind(format!("%{}%", r.address.unwrap_or_default()))
            .fetch_all(self.state.orm().get_executor())
            .await
            .into_app_err()?;
    
        let mut hm = HashMap::new();
        for row in rows {
            let a = row.attachment.into_attachments();
            let e = &mut hm
                .entry(row.project.uuid.clone())
                .or_insert_with(|| NamedProjectWithAttachments {
                    attachments: vec![],
                    project: row.project,
                })
                .attachments;
            let Some(a) = a else { continue };
            e.push(a);
        }
        let mut v = hm.into_values().collect::<Vec<_>>();
        v.sort_by(|a, b| b.project.created_at.cmp(&a.project.created_at));
        let result = GetProjectWithAttachmentResult {
            result: v,
            total: total,
        };

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn get_project_inspectors(&self, r: GetProjectInspectorsRequest, _t: AccessTokenPayload) -> Result<Response, AppErr> { 
        let inspectors = sqlx::query_as::<_, InspectorInfo>("
        select 
            u.fcs,
            u.\"uuid\"
        from project.iko_relationship ir
        left join auth.users u
            on u.\"uuid\" = ir.user_uuid
        where ir.project = $1
        ")
            .bind(&r.project_uuid)
            .fetch_all(self.state.orm().get_executor())
            .await
            .into_app_err()?;
        
        Ok((StatusCode::OK, Json(GetProjectInspectorsResponse{inspectors: inspectors})).into_response())
    }


    async fn get_project(&self, r: GetProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let (offset, limit) = r.pagination.map(|p| (p.offset, p.limit)).unwrap_or((0, 0));

        let address = r.address.unwrap_or_default().trim().to_string();

        let mut cq: String = "SELECT COUNT(*) FROM project.project p {{ADDRESS_RULE}} {{ROLE_RULE}}".to_string();
        let addr = address.clone();
        let replace_addr = move |cq: String, i: usize| -> String {
            if addr.is_empty() {
                cq.replace("{{ADDRESS_RULE}}", "")
            } else {
                cq.replace("{{ADDRESS_RULE}}", &format!("WHERE p.address like {}", <crate::DB as SqlGen>::placeholder(i)))
            }
        };

        let role = t.role.clone();
        let replace_role = move |cq: String, i: usize| -> Result<String, AppErr> {
            let cq = cq.replace("{{ROLE_RULE}}", &match role.as_str() {
                FOREMAN_ROLE => format!(" AND p.foreman = {} ", <crate::DB as SqlGen>::placeholder(i)),
                CUSTOMER_ROLE => format!(" AND p.created_by = {} ", <crate::DB as SqlGen>::placeholder(i)),
                // INSPECTOR_ROLE => format!(" inner join project.iko_relationship ir on ir.project = p.uuid AND ir.user_uuid = {} ", <crate::DB as SqlGen>::placeholder(i)),
                INSPECTOR_ROLE => format!(" AND {}::uuid IS NOT NULL ", <crate::DB as SqlGen>::placeholder(i)),
                ADMINISTRATOR_ROLE => format!(" AND {}::boolean IS NOT NULL ", <crate::DB as SqlGen>::placeholder(i)),
                _ => {
                    return Err(AppErr::default()
                        .with_err_response("Unknown role")
                        .with_status(StatusCode::FORBIDDEN));
                }
            });
            let cq = if cq.contains("WHERE") {cq} else {cq.replace("AND", "WHERE")};
            tracing::warn!("CQ: {}", cq);
            Ok(cq)
        };
       

        let mut q = match t.role.as_str() {
            FOREMAN_ROLE => {
                cq = replace_role(replace_addr(cq.clone(), 1), 0)?;
                sqlx::query_as::<_, (i64,)>(&cq)
                    .bind(t.uuid)
            }
            CUSTOMER_ROLE => {
                cq = replace_role(replace_addr(cq.clone(), 1), 0)?;
                sqlx::query_as::<_, (i64,)>(&cq)
                    .bind(t.org)
            }
            INSPECTOR_ROLE => {
                cq = replace_role(replace_addr(cq.clone(), 1), 0)?;
                sqlx::query_as::<_, (i64,)>(&cq)
                    .bind(t.uuid)
            }
            ADMINISTRATOR_ROLE => {
                cq = replace_role(replace_addr(cq.clone(), 1), 0)?;
                sqlx::query_as::<_, (i64,)>(&cq)
                    .bind(true)
            }
            _ => {
                return Err(AppErr::default()
                    .with_err_response("Unknown role")
                    .with_status(StatusCode::FORBIDDEN));
            }
        };

        
        if !address.is_empty() {q = q.bind(format!("%{}%", address))}


        let total: i64 = q
            .fetch_one(self.state.orm().get_executor())
            .await
            .into_app_err()?.0;

        if limit <= 0 {
            return Ok((
                StatusCode::OK,
                Json(GetProjectResult {
                    result: vec![],
                    total: total,
                }),
            )
                .into_response());
        }

        let mut qstr = "
            WITH proj_page AS (
                SELECT 
                p.*,
                uf.fcs AS foreman,
                ao.name AS created_by
                FROM project.project p
                LEFT JOIN auth.users uf
                    ON uf.uuid = p.foreman
                left join auth.orgs ao
                    on ao.uuid = p.created_by
                {{ROLE_RULE}}
                AND p.address like $4
                ORDER BY p.created_at DESC
                OFFSET $1 LIMIT $2
            )
            SELECT pp.*,
                a.uuid AS attachment_uuid,
                a.original_filename,
                a.base_entity_uuid,
                a.content_type
            FROM proj_page pp
            LEFT JOIN attachment.attachments a 
                ON a.base_entity_uuid = pp.uuid;".to_string();
        
        
        let q = 
        match t.role.as_str() {
            FOREMAN_ROLE => {
                qstr = qstr.replace("{{ROLE_RULE}}", "WHERE p.foreman = $3");
                sqlx::query_as::<_, RowProjectWithAttachment>(&qstr)
                    .bind(offset)
                    .bind(limit)
                    .bind(t.uuid)
            }
            CUSTOMER_ROLE => {
                qstr = qstr.replace("{{ROLE_RULE}}", "WHERE p.created_by = $3");
                sqlx::query_as::<_, RowProjectWithAttachment>(&qstr)
                    .bind(offset)
                    .bind(limit)
                    .bind(t.org)
            }
            INSPECTOR_ROLE => {
                // qstr = qstr.replace("{{ROLE_RULE}}", "inner join project.iko_relationship ir on ir.project = p.uuid WHERE ir.user_uuid = $3 AND");
                qstr = qstr.replace("{{ROLE_RULE}}", "WHERE $3::uuid IS NOT NULL");
                sqlx::query_as::<_, RowProjectWithAttachment>(&qstr)
                    .bind(offset)
                    .bind(limit)
                    .bind(t.uuid)
            }
            ADMINISTRATOR_ROLE => {
                qstr = qstr.replace("{{ROLE_RULE}}", "WHERE $3::boolean IS NOT NULL");
                sqlx::query_as::<_, RowProjectWithAttachment>(&qstr)
                    .bind(offset)
                    .bind(limit)
                    .bind(true)
            }
            _ => {
                return Err(AppErr::default()
                    .with_err_response("Unknown role")
                    .with_status(StatusCode::FORBIDDEN));
            }
        };


        let rows = q
            .bind(format!("%{}%", address))
            .fetch_all(self.state.orm().get_executor())
            .await
            .into_app_err()?;

        let mut hm = HashMap::new();
        for row in rows {
            let a = row.attachment.into_attachments();
            let e = &mut hm
                .entry(row.project.uuid.clone())
                .or_insert_with(|| NamedProjectWithAttachments {
                    attachments: vec![],
                    project: row.project,
                })
                .attachments;
            let Some(a) = a else { continue };
            e.push(a);
        }
        let mut v = hm.into_values().collect::<Vec<_>>();
        v.sort_by(|a, b| b.project.created_at.cmp(&a.project.created_at));
        let result = GetProjectWithAttachmentResult {
            result: v,
            total: total,
        };

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn create_project(
        &self,
        r: CreateProjectRequest,
        t: AccessTokenPayload,
    ) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        let addr = r.address.map(|addr| (addr)).ok_or(
            AppErr::default()
                .with_err_response("address is empty")
                .with_status(StatusCode::BAD_REQUEST),
        )?;

        project.created_by = Set(Some(t.org));
        project.address = Set(addr);

        // let polygon = r
        //     .polygon
        //     .map(|poly| serde_json::from_str(&poly).into_app_err())
        //     .ok_or(
        //         AppErr::default()
        //             .with_err_response("polygon is uncorrected value")
        //             .with_status(StatusCode::BAD_REQUEST),
        //     )?;
        // let ssk = r.ssk.and_then(|sk| uuid::Uuid::parse_str(&sk).ok()).ok_or(
        //     AppErr::default()
        //         .with_err_response("ssk is invalid uuid")
        //         .with_status(StatusCode::BAD_REQUEST),
        // )?;

        project.polygon = r.polygon.map(|v|Set(v)).unwrap_or_default();
        // project.ssk = r.ssk.map(|v|Set(v)).unwrap_or_default();
        project.status = Set(ProjectStatus::New as i32);

        let res = self
            .state
            .orm()
            .project()
            .save(project, orm::prelude::SaveMode::Insert)
            .await
            .into_app_err()?
            .and_then(|res| Some(res))
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn set_project_foreman(&self, r: SetProjectForemanRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let pattern = format!("%{} {} {}%", r.last_name, r.first_name, r.patronymic);
        #[derive(sqlx::FromRow, serde::Deserialize)]
        struct Foreman {uuid: Uuid}
        let id = sqlx::query_as::<_, Foreman>("select * from auth.users where fcs ilike $1")
            .bind(pattern)
            .fetch_optional(self.state.orm().get_executor())
            .await
            .into_app_err()?
            .ok_or(
                AppErr::default()
                    .with_err_response("foreman not found")
                    .with_status(StatusCode::NOT_FOUND),
            )?
            .uuid; 

        let r = sqlx::query_as::<_, Project>("
            UPDATE project.project 
            SET foreman = $1
            WHERE created_by = $2
            AND status = $3
            AND uuid = $4
            RETURNING *
        ")
            .bind(id)
            .bind(&t.org)
            .bind(&(ProjectStatus::New as i32))
            .bind(&r.uuid)
            .fetch_optional(self.state.orm().get_executor())
            .await
            .into_app_err()?;

        let res = r.ok_or(
            AppErr::default()
                .with_err_response("project not found or you are not allowed to update it")
                .with_status(StatusCode::NOT_FOUND),
        )?;

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn activate_project(&self, r: ProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let mut tx : OrmTX<crate::DB> = self.state.orm().begin_tx().await.into_app_err()?;
        let project = sqlx::query_as::<_, Project>("
            UPDATE project.project 
            SET status = $1
            WHERE uuid = $2 AND status = $3
            RETURNING *
        ")
            .bind(ProjectStatus::Normal as i32)
            .bind(&r.project_uuid)
            .bind(ProjectStatus::PreActive as i32)
            .fetch_optional(tx.get_inner())
            .await
            .into_app_err()?;
    
        let mut iko = ActiveIkoRelationship::default();
        iko.project = Set(r.project_uuid);
        iko.user_uuid = Set(Some(t.uuid));

        let res = tx
            .iko_relationship()
            .save(iko, orm::prelude::SaveMode::Insert)
            .await
            .into_app_err();
        if let Err(e) = res {
            tx.rollback().await.into_app_err()?;
            return Err(e);
        }
        tx.commit().await.into_app_err()?;
        
        return Ok((StatusCode::OK, Json(project)).into_response());
    }

    async fn commit_project(
        &self,
        r: ProjectRequest,
        t: AccessTokenPayload,
    ) -> Result<Response, AppErr> {
        let project = sqlx::query_as::<_, Project>("
            UPDATE project.project 
            SET status = $1
            WHERE uuid = $2 AND status = $3 AND created_by = $4
            RETURNING *
        ")
        .bind(ProjectStatus::PreActive as i32)
        .bind(&r.project_uuid)
        .bind(ProjectStatus::New as i32)
        .bind(&t.org)
        .fetch_optional(self.state.orm().get_executor())
        .await
        .into_app_err()?
        .ok_or(
            AppErr::default()
                .with_err_response("project not found or you are not allowed to commit it")
                .with_status(StatusCode::NOT_FOUND),
        )?;
        return Ok((StatusCode::OK, Json(project)).into_response());
    }

    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let mut iko = ActiveIkoRelationship::default();
        iko.project = Set(r.project_uuid);
        iko.user_uuid = Set(Some(t.uuid));

        let res = self
            .state
            .orm()
            .iko_relationship()
            .save(iko, orm::prelude::SaveMode::Insert)
            .await
            .into_app_err()?
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn get_project_statuses(&self) -> Result<Response,AppErr> {
        let res = self.state.orm().project_statuses().select("select * from norm.project_statuses").fetch().await.into_app_err()?;
        
        let result = &ProjectStatusesResponse{data: res};
        return Ok((StatusCode::OK, Json(result)).into_response())
    }
}

pub fn new_project_service(state: AppState) -> Arc<dyn IProjectService> {
    return Arc::new(ProjectService { state });
}

#[async_trait]
pub trait IProjectScheduleService: Send + Sync {
    async fn create_project_schedule(
        &self,
        r: CreateProjectScheduleRequest,
        t : AccessTokenPayload
    ) -> Result<Response, AppErr>;
    async fn set_works_in_schedule(
        &self,
        r: SetWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;
    async fn update_works_in_schedule(
        &self,
        r: SetWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;

    async fn get_project_schedule(
        &self, 
        r: GetProjectScheduleRequest, 
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;
    
    async fn delete_project_schedule(
        &self, 
        r: DeleteProjectScheduleRequest, 
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct ProjectScheduleService {
    state: AppState,
}

#[async_trait]
impl IProjectScheduleService for ProjectScheduleService {
    async fn create_project_schedule(
        &self,
        r: CreateProjectScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr> {
        // TODO: CHECK OWNERSHIP AND PROJECT STATUS
        let mut project_schedule = ActiveProjectSchedule::default();
        project_schedule.project_uuid = Set(r.project_uuid);
        project_schedule.work_category = Set(r.work_uuid);

        let res = self
            .state
            .orm()
            .project_schedule()
            .save(project_schedule, Insert)
            .await
            .into_app_err()?
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn update_works_in_schedule(
        &self,
        r: SetWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr> {
        let mut tx: OrmTX<crate::DB> = self.state.orm().begin_tx().await.into_app_err()?;
        #[derive(sqlx::FromRow, Debug)]
        pub struct LocalProjectFields {
            pub start_date: Option<chrono::NaiveDate>,
            pub end_date: Option<chrono::NaiveDate>,
        }
        
        let res = sqlx::query_as::<_, LocalProjectFields>("WITH updated AS (
    UPDATE journal.project_schedule_items psi
    SET is_deleted = TRUE
    FROM journal.project_schedule ps
    JOIN project.project p ON ps.project_uuid = p.uuid
    WHERE psi.project_schedule_uuid = ps.uuid
      AND psi.project_schedule_uuid = $1
      AND p.created_by = $2
      AND p.status = $3
    RETURNING p.uuid AS project_id
)
SELECT project_id FROM updated
UNION ALL
SELECT p.uuid AS project_id
FROM journal.project_schedule ps
JOIN project.project p ON ps.project_uuid = p.uuid
WHERE ps.uuid = $1
  AND p.created_by = $2
  AND p.status = $3
LIMIT 1")
            .bind(&r.project_schedule_uuid)
            .bind(&t.org)
            .bind(&(ProjectStatus::New as i32))
            .fetch_optional(tx.get_inner())
            .await
            .into_app_err()?;
        let Some(LocalProjectFields { start_date, end_date }) = res else {
            tx.rollback().await.into_app_err()?;
            return Err(AppErr::default()
                .with_err_response("project schedule not found or you are not allowed to update it")
                .with_status(StatusCode::FORBIDDEN));
        };
        
        let mut out = vec![];
        for r in r.items {
            let mut work_to_update = ActiveProjectScheduleItems::default();
            if let Some(start) = &start_date {
                if &r.start_date < start {
                    return Err(AppErr::default()
                        .with_err_response("start date cannot be less than project start date")
                        .with_status(StatusCode::BAD_REQUEST));
                }
            }
            if let Some(end) = &end_date {
                if &r.end_date > end {
                    return Err(AppErr::default()
                        .with_err_response("end date cannot be more than project end date")
                        .with_status(StatusCode::BAD_REQUEST));
                }
            }
            work_to_update.end_date = Set(r.end_date);
            work_to_update.start_date = Set(r.start_date);
            work_to_update.updated_by = Set(Some(t.uuid));
            work_to_update.measurement = Set(r.measurement);
            work_to_update.title = Set(r.title);
            work_to_update.is_deleted = Set(false);
            work_to_update.uuid = r.uuid.map(|v|Set(v)).unwrap_or_default();
            let res = tx
                .project_schedule_items()
                .save(work_to_update, Upsert)
                .await
                .into_app_err()?
                .ok_or(
                    AppErr::default()
                        .with_err_response("internal database error")
                        .with_status(StatusCode::INTERNAL_SERVER_ERROR),
                )?;
            out.push(res)
        }
        return Ok((StatusCode::OK, Json(out)).into_response());
    }

    async fn set_works_in_schedule(
        &self,
        r: SetWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>{
        let mut result: Vec<ProjectScheduleItems> = Vec::new();

        let mut tx = self.state.orm().begin_tx().await.into_app_err()?;

        #[derive(sqlx::FromRow, Debug)]
        pub struct ProjectId {
            pub project_id: Uuid,
        }
        
        let res = sqlx::query_as::<_, ProjectId>("WITH updated AS (
    UPDATE journal.project_schedule_items psi
    SET is_deleted = TRUE
    FROM journal.project_schedule ps
    JOIN project.project p ON ps.project_uuid = p.uuid
    WHERE psi.project_schedule_uuid = ps.uuid
      AND psi.project_schedule_uuid = $1
      AND p.created_by = $2
      AND p.status = $3
    RETURNING p.uuid AS project_id
)
SELECT project_id FROM updated
UNION ALL
SELECT p.uuid AS project_id
FROM journal.project_schedule ps
JOIN project.project p ON ps.project_uuid = p.uuid
WHERE ps.uuid = $1
  AND p.created_by = $2
  AND p.status = $3
LIMIT 1")
            .bind(&r.project_schedule_uuid)
            .bind(&t.org)
            .bind(&(ProjectStatus::New as i32))
            .fetch_optional(tx.get_inner())
            .await
            .into_app_err()?;
        let Some(ProjectId { project_id }) = res else {
            tx.rollback().await.into_app_err()?;
            return Err(AppErr::default()
                .with_err_response("project schedule not found or you are not allowed to update it")
                .with_status(StatusCode::FORBIDDEN));
        };

        let mut max_date: Option<chrono::NaiveDate> = None;
        let mut min_date: Option<chrono::NaiveDate> = None;
        for (index, elem) in r.items.into_iter().enumerate() {
            if elem.start_date > elem.end_date {
                return Err(AppErr::default()
                    .with_err_response("end date must be greater than start date")
                    .with_status(StatusCode::BAD_REQUEST));
            }

            if let Some(max) = max_date {
                max_date = Some(max.max(elem.end_date));
            } else {
                max_date = Some(elem.end_date)
            }
            if let Some(min) = min_date {
                min_date = Some(min.min(elem.start_date));
            } else {
                min_date = Some(elem.start_date)
            }

            let work_to_schedule = ActiveProjectScheduleItems {
                start_date: Set(elem.start_date),
                end_date: Set(elem.end_date),
                target_volume: Set(elem.target_volume),
                is_deleted: Set(false),
                project_schedule_uuid: Set(r.project_schedule_uuid.clone()),
                is_completed: Set(elem.is_complete),
                updated_by: Set(Some(t.uuid)),
                title: Set(elem.title),
                is_draft: Set(t.role == FOREMAN_ROLE),
                created_by: Set(t.org),
                measurement: Set(elem.measurement),
                uuid: elem.uuid.map(|u| Set(u)).unwrap_or_default(),
            };



            let maybe_elem = self
                .state
                .orm()
                .project_schedule_items()
                .save(work_to_schedule, Upsert)
                .await
                .into_app_err()?;

            let elem = match maybe_elem {
                Some(e) => e,
                None => {
                    tx.rollback().await.map_err(|e| {
                        AppErr::default()
                            .with_err_response(&format!("rollback failed: {e}"))
                            .with_status(StatusCode::INTERNAL_SERVER_ERROR)
                    })?;

                    return Err(AppErr::default()
                        .with_err_response("internal database error")
                        .with_status(StatusCode::INTERNAL_SERVER_ERROR));
                }
            };

            result.insert(index, elem);
        }

        let mut p = ActiveProject::default();
        p.uuid = Set(project_id);
        p.start_date = Set(min_date);
        p.end_date = Set(max_date);

        let t = tx
            .project()
            .save(p, SaveMode::Update)
            .await.into_app_err()?;
        let Some(_t) = t else {
            tx.rollback().await.into_app_err()?;
            return Err(AppErr::default()
                .with_err_response("internal database error")
                .with_status(StatusCode::INTERNAL_SERVER_ERROR));
        };
        tx.commit().await?;

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn get_project_schedule(&self, r: GetProjectScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let sch = sqlx::query_as::<_, TitledSchedule>("
            SELECT ps.uuid AS uuid,
            w.title AS title
            FROM journal.project_schedule ps
            JOIN norm.work_category w
            ON ps.work_category = w.uuid
            JOIN project.project p
            ON ps.project_uuid = p.uuid
            WHERE ps.project_uuid = $1
            AND p.created_by = $2")
            .bind(&r.project_uuid)
            .bind(&t.org)
            .fetch_all(self.state.orm().get_executor())
            .await
            .into_app_err()?;
        let mut result = vec![];
        for schedule in sch {
            let items = self.state.orm().project_schedule_items()
                .select("select * from journal.project_schedule_items where project_schedule_uuid = $1 AND is_deleted = FALSE")
                .bind(&schedule.uuid)
                .fetch().await
                .into_app_err()?
                .into_iter()
                .map(|v| ProjectScheduleItemResponse::from_items(v))
                .collect();
            result.push(ProjectScheduleCategoryPartResponse {
                uuid: schedule.uuid,
                title: schedule.title,
                items
            })
        }
        return Ok((StatusCode::OK, Json(GetProjectScheduleResponse{data: result})).into_response());
    }

    async fn delete_project_schedule(&self, r: DeleteProjectScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let mut tx = self.state.orm().begin_tx().await.into_app_err()?;

        let res = sqlx::query_as::<_, ProjectSchedule>("
            UPDATE journal.project_schedule ps
            SET is_deleted = TRUE
            FROM project.project p
            WHERE ps.project_uuid = p.uuid
            AND ps.uuid = $1
            AND p.status = $2
            AND p.created_by = $3
            RETURNING ps.*")
            .bind(&r.project_schedule_uuid)
            .bind(&(ProjectStatus::New as i32))
            .bind(&t.org)
            .fetch_optional(tx.get_inner())
            .await
            .into_app_err();
        
        let res = match res {
            Ok(v) => v,
            Err(e) => {
                tx.rollback().await.into_app_err()?;
                return Err(e);
            }
        };
        if res.is_none() {
            return Err(AppErr::default()
                .with_err_response("project schedule not found or you are not allowed to delete it")
                .with_status(StatusCode::FORBIDDEN));
        }

        let res = sqlx::query("
            UPDATE journal.project_schedule_items
            SET is_deleted = TRUE
            WHERE project_schedule_uuid = $1")
            .bind(&r.project_schedule_uuid)
            .fetch_all(tx.get_inner())
            .await
            .into_app_err();

        if let Err(e) = res {
            tx.rollback().await.into_app_err()?;
            return Err(e);
        };

        tx.commit().await.into_app_err()?;
        return Ok((StatusCode::OK).into_response());
    }
}

pub fn new_project_schedule_service(state: AppState) -> Arc<dyn IProjectScheduleService> {
    return Arc::new(ProjectScheduleService { state });
}

#[async_trait]
pub trait IWorkCategoryService: Send + Sync {
    async fn create_work_category(&self, r: CreateWorkCategoryRequest) -> Result<Response, AppErr>;
    async fn update_work_category(&self, r: UpdateWorkCategoryRequest) -> Result<Response, AppErr>;
    async fn get_work_categories(&self) -> Result<Response, AppErr>;
    async fn get_kpgz_vec(&self) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct WorkCategoryService {
    state: AppState,
}

#[async_trait]
impl IWorkCategoryService for WorkCategoryService {
    async fn create_work_category(&self, r: CreateWorkCategoryRequest) -> Result<Response, AppErr> {
        let cat = ActiveWorkCategory {
            kpgz: Set(r.kpgz),
            title: Set(r.title),
            ..Default::default()
        };

        let res = self
            .state
            .orm()
            .work_category()
            .save(cat, Insert)
            .await
            .into_app_err();
        let res = match res {Ok(res) => res, Err(mut e) => {
            let err = e.to_string();
            if err.contains("work_category_kpgz_id_fk") {
                e = e
                    .with_status(StatusCode::BAD_REQUEST)
                    .with_response("kpgz_id not found");
            }
            return Err(e);
        }};

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn update_work_category(&self, r: UpdateWorkCategoryRequest) -> Result<Response, AppErr> {
        let cat = ActiveWorkCategory {
            kpgz: match r.kpgz {
                Some(value) => Set(value),
                None => NotSet,
            },
            title: match r.title {
                Some(value) => Set(value),
                None => NotSet,
            },
            uuid: Set(r.uuid),
            ..Default::default()
        };

        let res = self
            .state
            .orm()
            .work_category()
            .save(cat, Update)
            .await
            .into_app_err()?;

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn get_work_categories(&self) -> Result<Response, AppErr> {
        let raw = self
            .state
            .orm()
            .work_category()
            .select("select * from norm.work_category")
            .fetch()
            .await
            .into_app_err()?;
        let result = GetWorkCategoriesResponse { items: raw };

        Ok((StatusCode::OK, Json(result)).into_response())
    }

    async fn get_kpgz_vec(&self) -> Result<Response, AppErr> {
        let raw = self
            .state
            .orm()
            .kpgz()
            .select("select * from norm.kpgz")
            .fetch()
            .await
            .into_app_err()?;
        let result = GetKpgz { items: raw };
        Ok((StatusCode::OK, Json(result)).into_response())
    }
}

pub fn new_work_category_service(state: AppState) -> Arc<dyn IWorkCategoryService> {
    return Arc::new(WorkCategoryService { state: state });
}

#[async_trait]
pub trait IWorkService: Send + Sync {
    async fn get_measurements(&self) -> Result<Response, AppErr>;
}

#[derive(Clone)]
struct WorkService {
    state: AppState,
}
#[async_trait]
impl IWorkService for WorkService {
    async fn get_measurements(&self) -> Result<Response, AppErr> {
        Ok((StatusCode::OK, Json(self.state.orm().measurements().select("").fetch().await.into_app_err()?)).into_response())
    }
}

pub fn new_work_service(state: AppState) -> Arc<dyn IWorkService> {
    return Arc::new(WorkService { state: state });
}
