use std::collections::HashMap;
use std::sync::Arc;

use axum::response::IntoResponse;
use async_trait::async_trait;
use axum::{Json, http::StatusCode, response::Response};
use orm::prelude::Optional::Set;
use orm::prelude::SaveMode::{Insert, Update};
use schema::prelude::{ActiveIkoRelationship, ActiveProject, ActiveProjectSchedule, ActiveProjectScheduleItems, Attachments, OrmIkoRelationship, OrmProject, OrmProjectSchedule, OrmProjectScheduleItems, OrmWorkCategory, Project, ProjectScheduleItems};
use shared::prelude::IntoAppErr;
use shared::prelude::{AppErr};
use uuid::Uuid;

use crate::AppState;
use crate::entities::*;

#[async_trait]
pub trait IProjectService: Send + Sync {
    async fn get_project(&self, r: GetProjectRequest) -> Result<Response, AppErr>;
    async fn create_project(&self, r: CreateProjectRequest) -> Result<Response, AppErr>;
    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr>;
    async fn activate_project(&self, r: ActivateProjectRequest) -> Result<Response, AppErr>;
    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest) -> Result<Response,AppErr>;
}

#[derive(Clone)]
struct ProjectService {
    state: AppState,
}

#[async_trait]
impl IProjectService for ProjectService {
    async fn get_project(&self, r: GetProjectRequest) -> Result<Response, AppErr> {
        let (offset, limit) = r.pagination.map(|p| (p.offset, p.limit)).unwrap_or((0, 0));

        let address = r.address.map(|addr| (addr)).ok_or(
            AppErr::default()
                .with_err_response("address is empty")
                .with_status(StatusCode::BAD_REQUEST),
        )?;

        if limit <= 0 {
            let total: (i64,) = sqlx::query_as::<_, (i64,)>(
                "SELECT COUNT(*) FROM project.project WHERE address like $1",
            )
            .bind(format!("%{}%", address))
            .fetch_one(self.state.orm().get_executor())
            .await
            .into_app_err()?;
            return Ok((StatusCode::OK, Json(GetProjectResult {
                result: vec![],
                total: total.0,
            })).into_response());
        }

        let rows = sqlx::query_as::<_, RowProjectWithAttachment>("
            SELECT p.*, 
            a.uuid AS attachment_uuid,
            a.original_filename,
            a.base_entity_uuid,
            a.file_uuid,
            a.content_type,
            COUNT(*) OVER() AS total_count
            FROM project.project p 
            LEFT JOIN attachment.attachments a ON a.base_entity_uuid = p.uuid
            WHERE p.address like $1 offset $2 limit $3
        ")
            .bind(format!("%{}%", address))
            .bind(offset)
            .bind(limit)
            .fetch_all(self.state.orm().get_executor())
            .await
            .into_app_err()?;

        let mut hm = HashMap::new();
        let mut total = 0;
        for row in rows {
            let a = row.attachment.into_attachments();
            total = row.total_count;
            let e = &mut hm.entry(row.project.uuid.clone())
                .or_insert_with(|| ProjectWithAttachments {
                    attachments: vec![], 
                    project: row.project
                })
                .attachments;
            let Some(a) = a else {continue};
            e.push(a);  
        }
       
        let result = GetProjectWithAttachmentResult {
            result: hm.into_values().collect::<Vec<_>>(),
            total: total,
        };

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn create_project(&self, r: CreateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        let addr = r.address.map(|addr| (addr)).ok_or(
            AppErr::default()
                .with_err_response("address is empty")
                .with_status(StatusCode::BAD_REQUEST),
        )?;
        project.address = Set(addr);

        let polygon = r
            .polygon
            .map(|poly| serde_json::from_str(&poly).into_app_err())
            .ok_or(
                AppErr::default()
                    .with_err_response("polygon is uncorrected value")
                    .with_status(StatusCode::BAD_REQUEST),
            )?;
        project.polygon = Set(polygon?);

        let ssk = r.ssk.and_then(|sk| uuid::Uuid::parse_str(&sk).ok()).ok_or(
            AppErr::default()
                .with_err_response("ssk is invalid uuid")
                .with_status(StatusCode::BAD_REQUEST),
        )?;
        project.ssk = Set(Some(ssk));

        project.status = Set(0);

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

    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();

        r.foreman.and_then(|foreman| {
            Some(uuid::Uuid::parse_str(&foreman).and_then(|f| Ok(project.foreman = Set(Some(f)))))
        });

        match r.status {
            Some(raw_status) => {
                match ProjectStatus::try_from(raw_status) {
                    Ok(
                        s @ ProjectStatus::New
                        | s @ ProjectStatus::InActive
                        | s @ ProjectStatus::Suspend
                        | s @ ProjectStatus::Normal
                        | s @ ProjectStatus::LowPunishment
                        | s @ ProjectStatus::NormalPunishment
                        | s @ ProjectStatus::HighPunishment
                        | s @ ProjectStatus::SomeWarnings,
                    ) => Some(s),
                    Err(_) => {
                        return Err(AppErr::default()
                            .with_err_response("unsupported status number")
                            .with_status(StatusCode::BAD_REQUEST));
                    }
                }
            }
            None => None,
        }.and_then(|status| Some(project.status = Set(status as i32)));

        Uuid::parse_str(&r.uuid).and_then(|guid| Ok(project.uuid = Set(guid))).map_err(|e| AppErr::default().with_err_response(e.to_string().as_str()))?;

        let res = self.state.orm().project().save(project, orm::prelude::SaveMode::Update).await.into_app_err()?.and_then(|res| Some(res))
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response());   
    }

    async fn activate_project(&self, r: ActivateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();
        project.is_active = Set(true);
        project.uuid = Set(r.uuid);
        
        let res = self.state.orm().project().save(project, Update).await.into_app_err()?.ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        
        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest) -> Result<Response,AppErr>{
        let mut iko = ActiveIkoRelationship::default();
        iko.project = Set(r.project_uuid);
        iko.user_uuid = Set(Some(r.iko_uuid));
        
        let res = self.state.orm().iko_relationship().save(iko, orm::prelude::SaveMode::Insert).await.into_app_err()?.ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response())
    }
}

pub fn new_project_service(state: AppState) -> Arc<dyn IProjectService> {
    return Arc::new(ProjectService { state });
}

#[async_trait]
pub trait IProjectScheduleService: Send + Sync {
    async fn create_project_schedule(&self, r : CreateProjectScheduleRequest) -> Result<Response, AppErr>;
    async fn add_work_to_schedule(&self, r : AddWorkToScheduleRequest) -> Result<Response, AppErr>;
    async fn update_work_schedule(&self, r: UpdateWorkScheduleRequest) -> Result<Response, AppErr>;
    async fn update_works_in_schedule(&self, r: UpdateWorksInScheduleRequest) -> Result<Response, AppErr>;
    async fn get_project_schedule(&self, r : GetProjectScheduleRequest) -> Result<Response,AppErr>;
}

#[derive(Clone)]
struct ProjectScheduleService {
    state: AppState,
}

#[async_trait]
impl IProjectScheduleService for ProjectScheduleService {
    async fn create_project_schedule(&self, r : CreateProjectScheduleRequest) -> Result<Response, AppErr>{
        let mut project_schedule = ActiveProjectSchedule::default();
        project_schedule.start_date = Set(Some(r.start_date));
        project_schedule.end_date = Set(Some(r.end_date));
        project_schedule.project_uuid = Set(r.project_uuid);

       let res = self.state.orm().project_schedule().save(project_schedule, Insert).await.into_app_err()?.ok_or(AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        return Ok((StatusCode::OK, Json(res)).into_response())
    }

    async fn add_work_to_schedule(&self, r : AddWorkToScheduleRequest) -> Result<Response, AppErr>{
        let mut work_to_schedule = ActiveProjectScheduleItems::default();
        work_to_schedule.created_by = Set(r.created_by);
        work_to_schedule.work_uuid = Set(r.work_uuid);
        work_to_schedule.start_date = Set(r.start_date);
        work_to_schedule.end_date = Set(r.end_date);
        work_to_schedule.target_volume = Set(r.target_volume);
        work_to_schedule.is_draft = Set(r.is_draft);

        let res = self.state.orm().project_schedule_items().save(work_to_schedule, Insert).await.into_app_err()?.ok_or(AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;
        return Ok((StatusCode::OK, Json(res)).into_response())
    }

    async fn update_work_schedule(&self, r: UpdateWorkScheduleRequest) -> Result<Response, AppErr>{
        
        let mut result : Vec<ProjectScheduleItems> = Vec::new();

        let tx = self.state.orm().begin_tx().await.ok().unwrap();

        for (index, elem) in r.items.into_iter().enumerate() {
            let mut work_to_schedule = ActiveProjectScheduleItems::default();
            work_to_schedule.work_uuid = Set(elem.uuid);
            work_to_schedule.start_date = Set(elem.start_date);
            work_to_schedule.end_date = Set(elem.end_date);

            let maybe_elem = self
                .state
                .orm()
                .project_schedule_items()
                .save(work_to_schedule, Update)
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
        tx.commit().await?;

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn update_works_in_schedule(&self, r: UpdateWorksInScheduleRequest) -> Result<Response, AppErr>{
        let mut work_to_update = ActiveProjectScheduleItems::default();
        work_to_update.end_date = Set(r.end_date);
        work_to_update.start_date = Set(r.start_date);
        work_to_update.uuid = Set(r.uuid);


        let res = self.state.orm().project_schedule_items().save(work_to_update, Update).await.into_app_err()?.ok_or(AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
        )?;

        return Ok((StatusCode::OK, Json(res)).into_response())
    }
    
    async fn get_project_schedule(&self, r : GetProjectScheduleRequest) -> Result<Response,AppErr>{
        // Получаем график проекта
        let raw = self
            .state
            .orm()
            .project_schedule()
            .select("SELECT * FROM project_schedule WHERE project_uuid = $1 LIMIT 1")
            .bind(r.uuid)
            .fetch()
            .await?;

        let project_schedule = raw
            .get(0)
            .ok_or_else(|| AppErr::default()
                .with_err_response("internal database error")
                .with_status(StatusCode::INTERNAL_SERVER_ERROR))?;

        // Загружаем все категории за один раз
        let categories = self
            .state
            .orm()
            .work_category()
            .select("SELECT * FROM work_category")
            .fetch()
            .await?;

        use std::collections::HashMap;
        let mut category_map: HashMap<Uuid, String> = HashMap::new();
        for cat in categories {
            category_map.insert(cat.uuid, cat.title);
        }

        let project_schedule_items = self
            .state
            .orm()
            .project_schedule_items()
            .select("SELECT * FROM project_schedule_items WHERE project_schedule_uuid = $1")
            .bind(project_schedule.uuid)
            .fetch()
            .await?;

        let mut grouped: HashMap<String, Vec<ProjectScheduleItemResponse>> = HashMap::new();

        for item in project_schedule_items {
            let category_title = category_map
                .get(&item.work_uuid)
                .cloned()
                .unwrap_or_else(|| "Без категории".to_string());

            let entry = grouped.entry(category_title).or_insert_with(Vec::new);

            entry.push(ProjectScheduleItemResponse {
                //title: item.title.clone(),
                title: "".to_string(),
                start_date: item.start_date,
                end_date: item.end_date,
            });
        }

        // Собираем финальный результат
        let mut result_items: Vec<ProjectScheduleCategoryPartResponse> = Vec::new();

        for (title, items) in grouped {
            result_items.push(ProjectScheduleCategoryPartResponse {
                title,
                items: Some(items),
            });
        }
        let result = GetProjectScheduleResponse{items: result_items};

        return Ok((StatusCode::OK, Json(result)).into_response())
    }
}

pub fn new_project_schedule_service(state: AppState) -> Arc<dyn IProjectScheduleService> {
    return Arc::new(ProjectScheduleService { state });
}