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