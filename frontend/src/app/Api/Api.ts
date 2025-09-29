"use client"

import {jwtDecode} from "jwt-decode";
import {WorkItem} from "@/models";

const baseURL = "https://test.foxstudios.ru:32460/Vadim/api";

interface TokenPayload {
    exp: number;
    uuid: string;
    role: string;
    org: string;
}

export async function AuthUser(login: string, password: string) {
    try {
        const response = await fetch(`http://81.200.145.130:32460/api/auth/session`, {
            method: "POST",
            credentials: "include",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ login, password })
        });

        const result = await response.json();
        const token = result.access_token;
        localStorage.setItem("access_token", token);
        const decoded = jwtDecode<TokenPayload>(token);

        return { success: true, message: result.message, decoded };
    } catch (error) {
        console.error("Ошибка при авторизации:", error);
        return { success: false, message: String(error) };
    }
}

export async function CreateObject(address: string, polygon: string) {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/create-project`, {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({ address, polygon })
        });

        if (!response.ok) {
            const result = await response.json();
            return { success: false, message: result.message }
        }

        const result = await response.json();
        return { success: true, message: null, result: result.uuid };

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { success: false, message: String(error) };
    }
}

export async function GetProjectSchedule(project_uuid:string){
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/get-project-schedule`, {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body: JSON.stringify({ project_uuid })
        });
        if(response.ok){
            const result = await response.json();
            return { success: true, message: null, result: result};
        } else {
            const result = await response.json();
            return { success: false, message: result.message }
        }

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { success: false, message: String(error) };
    }
}

export async function GetWorkCategories(){
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/get-work-category`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if(response.ok){
            const result = await response.json();
            return { successCategories: true, messageCategories: null, resultCategories: result.items};
        } else {
            const result = await response.json();
            return { successCategories: false, messageCategories: result.message }
        }

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { successCategories: false, messageCategories: String(error) };
    }
}

export async function GetMeasurement(){
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/get-measurements`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if(response.ok){
            const result = await response.json();
            return { successMeasurement: true, messageMeasurement: null, resultMeasurement: result};
        } else {
            const result = await response.json();
            return { successMeasurement: false, messageMeasurement: result.message }
        }

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { successMeasurement: false, messageMeasurement: String(error) };
    }
}

export async function Getkpgz(){
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/get-kpgz-vec`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if(response.ok){
            const result = await response.json();
            return { successkpgz: true, messagekpgz: null, resultkpgz: result.items};
        } else {
            const result = await response.json();
            return { successkpgz: false, messagekpgz: result.message }
        }

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { successkpgz: false, messagekpgz: String(error) };
    }
}

export async function CreateProjectSchedule(projectUuid: string, workUuid: string): Promise<{ success: boolean; message: string | null; result?: { uuid: string }; }> {
    try {
        const token = localStorage.getItem("access_token");
        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/create-project-schedule`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`,
            },
            body: JSON.stringify({
                project_uuid: projectUuid,
                work_uuid: workUuid,
            }),
        });

        if (response.ok) {
            const result: { uuid: string } = await response.json();
            return { success: true, message: null, result };
        } else {
            const result = await response.json();
            return { success: false, message: result.message };
        }
    } catch (error) {
        console.error("Ошибка при создании project_schedule:", error);
        return { success: false, message: String(error) };
    }
}

export async function UpdateWorksInSchedule(items: WorkItem[], projectScheduleUuid: string){
    try {
        const token = localStorage.getItem("access_token");
        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/set-works-in-schedule`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`,
            },
            body: JSON.stringify({
                items,
                project_schedule_uuid: projectScheduleUuid,
            }),
        });

        if (response.ok) {
            await response.json();
            return { success: true, message: null };
        } else {
            const result = await response.json();
            return { success: false, message: result.message };
        }
    } catch (error) {
        console.error("Ошибка при обновлении works-in-schedule:", error);
        return { success: false, message: String(error) };
    }
}

export async function DeleteProjectSchedule(uuid: string) {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const response = await fetch(`${baseURL}/project/project-schedule?project_schedule_uuid=${uuid}`, {
            method: "DELETE",
            headers: {
                "Authorization": `Bearer ${token}`,
                "Content-Type": "application/json",
            },
        });

        if (response.ok) {
            return { success: true, message: "Этап успешно удалён" };
        } else {
            const result = await response.json();
            return { success: false, message: result.message || "Ошибка при удалении" };
        }
    } catch (error) {
        console.error("Ошибка удаления:", error);
        return { success: false, message: String(error) };
    }
}

export async function GetProjects(offset: number, limit: number) {
    const token = localStorage.getItem("access_token");

    if (!token) {
        return { success: false, message: "Нет access_token в localStorage", result: [] };
    }

    const response = await fetch(`${baseURL}/project/get-project`, {
        method: "POST",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
            "Authorization": `Bearer ${token}`
        },
        body: JSON.stringify({
            address: null,
            pagination: { limit, offset },
        }),
    });

    const data = await response.json();

    if (response.ok && Array.isArray(data.result)) {
        return { success: true, message: null, result: data.result, total: data.total || 0 };
    } else {
        return { success: false, message: data.message || "Ошибка при получении проектов", result: [] };
    }
}

export async function GetStatuses() {

    const response = await fetch(`${baseURL}/project/get-statuses`, {
        method: "GET",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
    });

    const data = await response.json();

    if (response.ok && Array.isArray(data.data)) {
        return { success: true, message: null, result: data.data };
    }

    return { success: false, message: data.message || "Ошибка при получении статусов", result: [] };
}

export async function DownloadAttachment(uuid: string) {

    const response = await fetch(`${baseURL}/attachmentproxy/file?file_id=${uuid}`, {
        method: "GET",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
        },
    });

    const data = await response.json();

    if (response.ok) {
        return { success: true, message: null, result: data };
    }

    return { success: false, message: data.message || "Ошибка при получении файла", result: [] };
}
