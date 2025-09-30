
export interface LoginFormData {
  email: string;
  password: string;
}

export interface FirstStepForm {
  address: string;
  polygon: string;
  ssk: string;
}

export interface Item {
  uuid: string;
  title: string;
  start_date: string;
  end_date: string;
  is_completed: boolean;
  is_deleted: boolean;
  is_draft: boolean;
  measurement: number;
  target_volume: number;
}

export interface DataBlock {
  uuid: string;
  title: string;
  items: Item[];
}

export interface Works {
  kpgz: number;
  title: string;
  uuid: string;
}

export interface Measurement {
  id: number;
  title: string;
}

export interface Kpgz {
  code: string;
  id: number;
  title: string;
}


export interface WorkItem {
  end_date: string;
  is_complete: boolean;
  measurement: number | undefined;
  start_date: string;
  target_volume: number;
  title: string;
  uuid: string | null;
}

export interface SubJob {
  title: string;
  volume: number;
  unitOfMeasurement: string;
  startDate: string;
  endDate: string;
}

export interface Status {
  id: number;
  title: string;
}

export interface Report {
    uuid: string;
    report_date: string;
    check_date: string;
    project_schedule_item: string;
    status: number;
    title: string;
}

export interface Attachment {
    base_entity_uuid: string;
    content_type: string;
    uuid: string;
    original_filename: string;
}

export interface ReportItem {
    report: Report;
    attachments: Attachment[];
}

export interface PunishmentItem {
    comment: string ;
    correction_date_fact: string  ;
    correction_date_info: string ;
    correction_date_plan: string ;
    is_suspend: boolean;
    place: string ;
    punish_datetime: string ;
    punishment: string ;
    punishment_item_status: number ;
    regulation_doc: string ;
    title: string ;
    uuid: string ;
}

export interface Punishments {
    custom_number: string;
    punish_datetime: string;
    punishment_status: string;
    punishment: PunishmentItem;
    attachments: Attachment[];
}

interface MaterialItem{
    uuid: string;
    title: string;
    volume: number;
    measurement: number;
    delivery_date: string;
    on_research: boolean;
    project: string;
    created_at: string;
}

export interface MaterialResponse {
    attachments: Attachment[];
    material: MaterialItem;
}