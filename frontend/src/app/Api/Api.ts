"use client";

import {jwtDecode} from "jwt-decode";
import {WorkItem} from "@/models";

const baseURL = "https://test.foxstudios.ru:32460/Vadim/api";

const authBaseURL = 'https://sso.foxstudios.ru:32460/api'

interface TokenPayload {
    exp: number;
    uuid: string;
    role: string;
    org: string;
}

export async function AuthUser(login: string, password: string) {
    try {
        const response = await fetch(`${authBaseURL}/auth/session`, {
            method: "POST",
            credentials: "include",
            headers: {"Content-Type": "application/json"},
            body: JSON.stringify({login, password}),
        });

        const result = await response.json();
        const token = result.access_token;
        localStorage.setItem("access_token", token);
        const decoded = jwtDecode<TokenPayload>(token);

        return {success: true, message: result.message, decoded};
    } catch (error) {
        console.error("Ошибка при авторизации:", error);
        return {success: false, message: String(error)};
    }
}

export async function CreateObject(address: string, polygon: string) {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/create-project`, {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({address, polygon}),
        });

        if (!response.ok) {
            const result = await response.json();
            return {success: false, message: result.message};
        }

        const result = await response.json();
        return {success: true, message: null, result: result.uuid};
    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return {success: false, message: String(error)};
    }
}

export async function GetProjectSchedule(project_uuid: string) {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/get-project-schedule`, {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({project_uuid}),
        });
        if (response.ok) {
            const result = await response.json();
            return {success: true, message: null, result: result};
        } else {
            const result = await response.json();
            return {success: false, message: result.message};
        }
    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return {success: false, message: String(error)};
    }
}

export async function GetWorkCategories() {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/get-work-category`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if (response.ok) {
            const result = await response.json();
            return {
                successCategories: true,
                messageCategories: null,
                resultCategories: result.items,
            };
        } else {
            const result = await response.json();
            return {successCategories: false, messageCategories: result.message};
        }
    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return {successCategories: false, messageCategories: String(error)};
    }
}

export async function GetMeasurement() {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/get-measurements`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if (response.ok) {
            const result = await response.json();
            return {
                successMeasurement: true,
                messageMeasurement: null,
                resultMeasurement: result,
            };
        } else {
            const result = await response.json();
            return {successMeasurement: false, messageMeasurement: result.message};
        }
    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return {successMeasurement: false, messageMeasurement: String(error)};
    }
}

export async function Getkpgz() {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/get-kpgz-vec`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
            },
        });
        if (response.ok) {
            const result = await response.json();
            return {successkpgz: true, messagekpgz: null, resultkpgz: result.items};
        } else {
            const result = await response.json();
            return {successkpgz: false, messagekpgz: result.message};
        }
    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return {successkpgz: false, messagekpgz: String(error)};
    }
}

export async function CreateProjectSchedule(
    projectUuid: string,
    workUuid: string
): Promise<{
    success: boolean;
    message: string | null;
    result?: { uuid: string };
}> {
    try {
        const token = localStorage.getItem("access_token");
        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/create-project-schedule`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                project_uuid: projectUuid,
                work_uuid: workUuid,
            }),
        });

        if (response.ok) {
            const result: { uuid: string } = await response.json();
            return {success: true, message: null, result};
        } else {
            const result = await response.json();
            return {success: false, message: result.message};
        }
    } catch (error) {
        console.error("Ошибка при создании project_schedule:", error);
        return {success: false, message: String(error)};
    }
}

export async function UpdateWorksInSchedule(
    items: WorkItem[],
    projectScheduleUuid: string
) {
    try {
        const token = localStorage.getItem("access_token");
        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(`${baseURL}/project/set-works-in-schedule`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                items,
                project_schedule_uuid: projectScheduleUuid,
            }),
        });

        if (response.ok) {
            await response.json();
            return {success: true, message: null};
        } else {
            const result = await response.json();
            return {success: false, message: result.message};
        }
    } catch (error) {
        console.error("Ошибка при обновлении works-in-schedule:", error);
        return {success: false, message: String(error)};
    }
}

export async function DeleteProjectSchedule(uuid: string) {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return {success: false, message: "Нет access_token в localStorage"};
        }

        const response = await fetch(
            `${baseURL}/project/project-schedule?project_schedule_uuid=${uuid}`,
            {
                method: "DELETE",
                headers: {
                    Authorization: `Bearer ${token}`,
                    "Content-Type": "application/json",
                },
            }
        );

        if (response.ok) {
            return {success: true, message: "Этап успешно удалён"};
        } else {
            const result = await response.json();
            return {
                success: false,
                message: result.message || "Ошибка при удалении",
            };
        }
    } catch (error) {
        console.error("Ошибка удаления:", error);
        return {success: false, message: String(error)};
    }
}

export async function GetProjects(offset: number, limit: number) {
    const token = localStorage.getItem("access_token");

    if (!token) {
        return {
            success: false,
            message: "Нет access_token в localStorage",
            result: [],
        };
    }

    const response = await fetch(`${baseURL}/project/get-project`, {
        method: "POST",
        credentials: "include",
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
            address: null,
            pagination: {limit, offset},
        }),
    });

    const data = await response.json();

    if (response.ok && Array.isArray(data.result)) {
        return {
            success: true,
            message: null,
            result: data.result,
            total: data.total || 0,
        };
    } else {
        return {
            success: false,
            message: data.message || "Ошибка при получении проектов",
            result: [],
        };
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
        return {success: true, message: null, result: data.data};
    }

    return {
        success: false,
        message: data.message || "Ошибка при получении статусов",
        result: [],
    };
}

export async function uploadProjectFiles(
    projectId: string,
    files: File[] | FileList
) {
    const uploaded: string[] = [];
    const errors: string[] = [];

    for (const file of Array.from(files)) {
        const formData = new FormData();
        formData.append("file", file);

        try {
            const res = await fetch(`${baseURL}/attach/project?id=${projectId}`, {
                method: "POST",
                body: formData,
            });

            if (res.ok) {
                uploaded.push(file.name);
            } else {
                errors.push(file.name);
            }
        } catch (err) {
            console.error("Ошибка сети:", err);
            errors.push(file.name);
        }
    }

    return {uploaded, errors};
}

export async function LogOut() {
    try {
        const token = localStorage.getItem("access_token");

        if (!token) {
            return { success: false, message: "Нет access_token в localStorage" };
        }

        const res = await fetch(`${authBaseURL}/auth/session`, {
            method: "DELETE",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
        });

        if (res.ok) {
            localStorage.removeItem("access_token");
            window.location.href = "/sign_in/";

            return { success: true, message: "Вы успешно вышли" };
        } else {
            return { success: false, message: "Ошибка при удалении refresh токена" };
        }
    } catch (error) {
        console.error("Ошибка при выходе:", error);
        return { success: false, message: String(error) };
    }
}


export async function GetReports(uuid: string) {
    try {
        const response = await fetch(
            `${baseURL}/report/get_reports_by_uuid?project_uuid=${uuid}`,
            {
                method: "GET",
                credentials: "include",
                headers: {
                    "Content-Type": "application/json",
                },
            }
        );

        const data = await response.json();

        if (response.ok) {
            return {success: true, message: null, result: data};
        }
    } catch (error) {
        console.error("Ошибка при получении отчётов:", error);
        return {success: false, message: String(error), result: []};
    }
}

export async function setForeman(projectUuid: string, first_name: string, last_name: string, patronymic: string) {
    try {
        const token = localStorage.getItem("access_token");
        if (!token) return {success: false, message: "Нет access_token в localStorage"};

        const response = await fetch(`${baseURL}/project/set-foreman`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify({
                first_name,
                last_name,
                patronymic,
                uuid: projectUuid,
            }),
        });

        if (response.ok) {
            return {success: true, message: null};
        } else {
            const result = await response.json();
            return {success: false, message: result.message || "Ошибка при set-foreman"};
        }
    } catch (error) {
        console.error("Ошибка при set-foreman:", error);
        return {success: false, message: String(error)};
    }
}

export async function projectCommit(projectUuid: string) {
    try {
        const token = localStorage.getItem("access_token");
        if (!token) return {success: false, message: "Нет access_token в localStorage"};

        const response = await fetch(`${baseURL}/project/project-commit?project_uuid=${projectUuid}`, {
            method: "PUT",
            headers: {
                Authorization: `Bearer ${token}`,
            },
        });

        if (response.ok) {
            return {success: true, message: null};
        } else {
            const result = await response.json();
            return {success: false, message: result.message || "Ошибка при project-commit"};
        }
    } catch (error) {
        console.error("Ошибка при project-commit:", error);
        return {success: false, message: String(error)};
    }
}

export async function GetMaterialsById(id:string) {
    try {
        const response = await fetch(`${baseURL}/materials/by_project/${id}`, {
            method: "GET",
            headers: {
                "Content-Type": "application/json",
            },
        });

        if (response.ok) {
            const result = await response.json();
            return {
                successMaterials: true,
                messageMaterials: null,
                resultMaterials: result,
            };
        } else {
            const text = await response.text();
            let message: string;

            try {
                const parsed = JSON.parse(text);
                message = parsed.message || text;
            } catch {
                message = text;
            }

            return { successMaterials: false, messageMaterials: message };
        }
    } catch (error) {
        console.error("Ошибка при запросе материалов:", error);
        return { successMaterials: false, messageMaterials: String(error) };
    }
}

export async function GetPunishmentsById(id:string) {
    try {
        const token = localStorage.getItem("access_token");
        const response = await fetch(`${baseURL}/punishment/get_punishment_items_by_project?project_uuid=${id}`, {
            method: "GET",
            credentials: 'include',
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
        });

        if (response.ok) {
            const result = await response.json();
            return {
                successPunishment: true,
                messagePunishment: null,
                resultPunishment: result.punishments,
            };
        } else {
            const text = await response.text();
            let message: string;

            try {
                const parsed = JSON.parse(text);
                message = parsed.message || text;
            } catch {
                message = text;
            }

            return { successPunishment: false, messagePunishment: message };
        }
    } catch (error) {
        console.error("Ошибка при запросе предписаний:", error);
        return { successPunishment: false, messagePunishment: String(error) };
    }
}

export async function RequestResearch(id: string) {
    try {
        const response = await fetch(
            `${baseURL}/materials/request_research/${id}`,
            {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json",
                },
            }
        );

        if (response.ok) {
            return { success: true, message: "Запрос на исследование отправлен успешно" };
        } else {
            const text = await response.text();
            let message: string;

            try {
                const parsed = JSON.parse(text);
                message = parsed.message || text;
            } catch {
                message = text;
            }

            return { success: false, message };
        }
    } catch (error) {
        console.error("Ошибка при запросе исследования:", error);
        return { success: false, message: String(error) };
    }
}

export async function GetPunishmetStatuses() {
    try {
        const token = localStorage.getItem("access_token");
        const response = await fetch(`${baseURL}/punishment/get_statuses`, {
            method: "GET",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
        });
    
        const data = await response.json();
    
        if (response.ok) {
            return {success: true, message: null, result: data};
        }
    } catch (error) {
        console.error("Ошибка при запросе статусов:", error);
        return { successPunishment: false, messagePunishment: String(error) };
    }
}


export async function AddIkoToProject(uuid: string) {
    try {
        const token = localStorage.getItem("access_token");
        const response = await fetch(`${baseURL}/project/add-iko-to-project`, {
            method: "POST",
            credentials: "include",
            headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
            },
            body: JSON.stringify(uuid)
        });
    
        const data = await response.json();
    
        if (response.ok) {
            return {success: true, message: null, result: data};
        }
    } catch (error) {
        console.error("Ошибка при запросе статусов:", error);
        return { successPunishment: false, messagePunishment: String(error) };
    }
}