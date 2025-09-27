use std::collections::HashMap;
use std::sync::Arc;

use async_trait::async_trait;
use auth_jwt::structs::AccessTokenPayload;
use axum::response::IntoResponse;
use axum::{Json, http::StatusCode, response::Response};
use orm::prelude::Optional::{NotSet, Set};
use orm::prelude::SaveMode::{Insert, Update, Upsert};
use schema::prelude::{
    ActiveIkoRelationship, ActiveProject, ActiveProjectSchedule, ActiveProjectScheduleItems, ActiveWorkCategory, ActiveWorks, OrmIkoRelationship, OrmKpgz, OrmMeasurements, OrmProject, OrmProjectSchedule, OrmProjectScheduleItems, OrmProjectStatuses, OrmWorkCategory, OrmWorks, ProjectScheduleItems, Works
};
use shared::prelude::AppErr;
use shared::prelude::IntoAppErr;
use uuid::Uuid;

use crate::AppState;
use crate::entities::*;

#[async_trait]
pub trait IProjectService: Send + Sync {
    async fn get_project(&self, r: GetProjectRequest) -> Result<Response, AppErr>;
    async fn create_project(
        &self,
        r: CreateProjectRequest,
        t: AccessTokenPayload,
    ) -> Result<Response, AppErr>;
    async fn update_project(&self, r: UpdateProjectRequest) -> Result<Response, AppErr>;
    async fn activate_project(&self, r: ActivateProjectRequest) -> Result<Response, AppErr>;
    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest) -> Result<Response, AppErr>;
    async fn get_project_statuses(&self) -> Result<Response,AppErr>;
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
            return Ok((
                StatusCode::OK,
                Json(GetProjectResult {
                    result: vec![],
                    total: total.0,
                }),
            )
                .into_response());
        }

        let rows = sqlx::query_as::<_, RowProjectWithAttachment>(
            "
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
        ",
        )
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
            let e = &mut hm
                .entry(row.project.uuid.clone())
                .or_insert_with(|| ProjectWithAttachments {
                    attachments: vec![],
                    project: row.project,
                })
                .attachments;
            let Some(a) = a else { continue };
            e.push(a);
        }

        let result = GetProjectWithAttachmentResult {
            result: hm.into_values().collect::<Vec<_>>(),
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
        if t.role != "customer" {
            return Err(AppErr::default()
                .with_err_response("unsupported role")
                .with_status(StatusCode::FORBIDDEN));
        }

        // project.created_by = Set(Some(t.uuid));
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
            Some(raw_status) => match ProjectStatus::try_from(raw_status) {
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
            },
            None => None,
        }
        .and_then(|status| Some(project.status = Set(status as i32)));

        Uuid::parse_str(&r.uuid)
            .and_then(|guid| Ok(project.uuid = Set(guid)))
            .map_err(|e| AppErr::default().with_err_response(e.to_string().as_str()))?;

        let res = self
            .state
            .orm()
            .project()
            .save(project, orm::prelude::SaveMode::Update)
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

    async fn activate_project(&self, r: ActivateProjectRequest) -> Result<Response, AppErr> {
        let mut project = ActiveProject::default();
        project.is_active = Set(true);
        project.uuid = Set(r.uuid);

        let res = self
            .state
            .orm()
            .project()
            .save(project, Update)
            .await
            .into_app_err()?
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn add_iko_to_project(&self, r: AddIkoToProjectRequest) -> Result<Response, AppErr> {
        let mut iko = ActiveIkoRelationship::default();
        iko.project = Set(r.project_uuid);
        iko.user_uuid = Set(Some(r.iko_uuid));

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
    async fn add_work_to_schedule(&self, r: AddWorkToScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
    async fn update_works_in_schedule(
        &self,
        r: UpdateWorkScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;
    async fn update_work_in_schedule(
        &self,
        r: UpdateWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr>;

    async fn get_project_schedule(&self, r: GetProjectScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr>;
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
        let mut project_schedule = ActiveProjectSchedule::default();
        project_schedule.project_uuid = Set(r.project_uuid);
        // project_schedule.created_by = Set(t.uuid); // TODO!

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

    async fn add_work_to_schedule(&self, r: AddWorkToScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        let mut work_to_schedule = ActiveProjectScheduleItems::default();
        work_to_schedule.created_by = Set(r.created_by);
        work_to_schedule.work_uuid = Set(r.work_uuid);
        work_to_schedule.start_date = Set(r.start_date);
        work_to_schedule.end_date = Set(r.end_date);
        work_to_schedule.target_volume = Set(r.target_volume);
        work_to_schedule.is_draft = Set(r.is_draft);
        work_to_schedule.created_by = Set(t.uuid);

        let res = self
            .state
            .orm()
            .project_schedule_items()
            .save(work_to_schedule, Insert)
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
        r: UpdateWorkScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr> {
        let mut result: Vec<ProjectScheduleItems> = Vec::new();

        let tx = self.state.orm().begin_tx().await.ok().unwrap();

        for (index, elem) in r.items.into_iter().enumerate() {
            let mut work_to_schedule = ActiveProjectScheduleItems::default();
            elem.uuid.map(|uuid| work_to_schedule.work_uuid = Set(uuid));
            work_to_schedule.start_date = Set(elem.start_date);
            work_to_schedule.end_date = Set(elem.end_date);
            work_to_schedule.project_schedule_uuid = Set(elem.project_schedule_uuid);
            work_to_schedule.work_uuid = Set(elem.work_uuid);
            work_to_schedule.is_completed = Set(false);
            work_to_schedule.target_volume = Set(elem.target_volume);
            work_to_schedule.is_deleted = Set(false);
            work_to_schedule.is_completed = Set(elem.is_complete);
            work_to_schedule.updated_by = Set(Some(t.uuid));

            // TODO: починить токены и сделать логику выбора
            work_to_schedule.is_draft = Set(false);

            //TODO: починить токены и заменить это
            work_to_schedule.created_by =
                Set(Uuid::parse_str("cc867b0b-324b-4dec-a1d3-632efb588edd").unwrap());

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
        tx.commit().await?;

        return Ok((StatusCode::OK, Json(result)).into_response());
    }

    async fn update_work_in_schedule(
        &self,
        r: UpdateWorksInScheduleRequest,
        t: AccessTokenPayload
    ) -> Result<Response, AppErr> {
        let mut work_to_update = ActiveProjectScheduleItems::default();
        work_to_update.end_date = Set(r.end_date);
        work_to_update.start_date = Set(r.start_date);
        work_to_update.updated_by = Set(Some(t.uuid));
        work_to_update.measurement = Set(r.measurement);

        if let Some(uuid) = r.uuid {
            work_to_update.uuid = Set(uuid);
        }

        let res = self
            .state
            .orm()
            .project_schedule_items()
            .save(work_to_update, Upsert)
            .await
            .into_app_err()?
            .ok_or(
                AppErr::default()
                    .with_err_response("internal database error")
                    .with_status(StatusCode::INTERNAL_SERVER_ERROR),
            )?;

        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn get_project_schedule(&self, r: GetProjectScheduleRequest, t: AccessTokenPayload) -> Result<Response, AppErr> {
        // Получаем график проекта
        let raw = self
            .state
            .orm()
            .project_schedule()
            .select(
                "SELECT ps.* FROM journal.project_schedule ps
             INNER JOIN project.project pj ON ps.project_uuid = pj.uuid
             WHERE ps.project_uuid = $1 
             AND created_by = $2
             LIMIT 1
             ",
            )
            .bind(r.uuid)
            .bind(t.uuid)
            .fetch()
            .await
            .into_app_err()?;

        tracing::warn!("raw size: {}", raw.len());

        let project_schedule = raw.first().ok_or_else(|| {
            AppErr::default()
                .with_err_response("not found project_schedule")
                .with_status(StatusCode::NOT_FOUND)
        })?;

        tracing::warn!(
            "current schedule, project_schedule_uuid: {}",
            project_schedule.uuid
        );

        // Загружаем все категории
        let categories = self
            .state
            .orm()
            .work_category()
            .select("SELECT * FROM norm.work_category")
            .fetch()
            .await
            .into_app_err()?;

        tracing::warn!("category list size: {}", categories.len());

        let category_map: HashMap<Uuid, String> = categories
            .into_iter()
            .map(|cat| (cat.uuid, cat.title))
            .collect();

        for (k, v) in category_map.iter() {
            tracing::warn!("category uuid :{}, value: {}", k, v);
        }

        // Получаем элементы расписания
        let project_schedule_items = self
            .state
            .orm()
            .project_schedule_items()
            .select("SELECT * FROM journal.project_schedule_items WHERE project_schedule_uuid = $1 and is_deleted != true")
            .bind(project_schedule.uuid)
            .fetch()
            .await
            .into_app_err()?;

        // Собираем список всех work_uuid из элементов расписания
        let work_uuids: Vec<Uuid> = project_schedule_items
            .iter()
            .map(|item| item.work_uuid)
            .collect();

        // Если work_uuids пуст, возвращаем пустой ответ сразу
        if work_uuids.is_empty() {
            let result = GetProjectScheduleResponse { data: Vec::new() };
            return Ok((StatusCode::OK, Json(result)).into_response());
        }

        // Получаем работы только для этих work_uuid
        let works = self
            .state
            .orm()
            .works()
            .select("SELECT * FROM norm.works WHERE uuid = ANY($1)")
            .bind(&work_uuids)
            .fetch()
            .await
            .into_app_err()?;

        // Создаём map: work_uuid -> Works
        let work_map: HashMap<Uuid, Works> =
            works.into_iter().map(|work| (work.uuid, work)).collect();

        // Группируем элементы по категории: ключ (category_uuid, category_title)
        let mut grouped: HashMap<(Uuid, String), Vec<ProjectScheduleItemResponse>> = HashMap::new();

        for item in project_schedule_items {
            if let Some(work) = work_map.get(&item.work_uuid) {
                let category_uuid = work.work_category;

                let category_title = category_map
                    .get(&category_uuid)
                    .cloned()
                    .unwrap_or_else(|| "Без категории".to_string());

                grouped
                    .entry((category_uuid, category_title))
                    .or_default()
                    .push(ProjectScheduleItemResponse {
                        uuid: item.uuid.clone(),
                        title: work.title.clone(),
                        start_date: item.start_date,
                        end_date: item.end_date,
                        is_deleted: item.is_deleted,
                        is_draft: item.is_draft,
                        is_completed: item.is_completed,
                        measurement: item.measurement,
                        target_volume: item.target_volume,
                    });
            } else {
                tracing::warn!("Не найден work для work_uuid = {}", item.work_uuid);
            }
        }

        // Формируем ответ
        let result_items: Vec<ProjectScheduleCategoryPartResponse> = grouped
            .into_iter()
            .map(
                |((category_uuid, title), items)| ProjectScheduleCategoryPartResponse {
                    uuid: category_uuid,
                    title,
                    items: items,
                },
            )
            .collect();

        let result = GetProjectScheduleResponse { data: result_items };

        Ok((StatusCode::OK, Json(result)).into_response())
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
    async fn save_work(&self, r: CreateUpdateWorkRequest) -> Result<Response, AppErr>;
    async fn get_works_by_category(&self, r: GetWorksByCategoryRequest)
    -> Result<Response, AppErr>;
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
    async fn save_work(&self, r: CreateUpdateWorkRequest) -> Result<Response, AppErr> {
        let save_mode = r.uuid.map(|_| Update).unwrap_or(Insert);
        let mut work = ActiveWorks {
            title: Set(r.title),
            work_category: Set(r.work_category_uuid),
            ..Default::default()
        };

        if let Some(uuid) = r.uuid {
            work.uuid = Set(uuid)
        }

        let raw = self
            .state
            .orm()
            .works()
            .save(work, save_mode)
            .await
            .into_app_err()?;
        let res = SaveWorkResponse { items: raw };
        return Ok((StatusCode::OK, Json(res)).into_response());
    }

    async fn get_works_by_category(
        &self,
        r: GetWorksByCategoryRequest,
    ) -> Result<Response, AppErr> {
        let raw = self
            .state
            .orm()
            .works()
            .select("select * from norm.works where work_category = $1")
            .bind(r.work_category_uuid)
            .fetch()
            .await
            .into_app_err()?;
        let res = GetWorksByCategoryResponse { items: raw };
        return Ok((StatusCode::OK, Json(res)).into_response());
    }
}

pub fn new_work_service(state: AppState) -> Arc<dyn IWorkService> {
    return Arc::new(WorkService { state: state });
}
