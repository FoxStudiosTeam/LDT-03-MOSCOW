import { title } from "process";
import { string } from "yup";

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
