"use client"

const baseURL = "https://sso.foxstudios.ru:32460";

export async function AuthUser(login: string, password: string) {


    try {
        const response = await fetch(`${baseURL}/api/auth/session`, {
            method: "POST",
            credentials: "include",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ login, password })
        });

        const result = await response.json();
        console.log(result)
        return { success: response.ok, message: result.message, result: result.result };
    }catch (error) {
        console.error("Ошибка при авторизации:", error);
        return { success: false, message: "Ошибка соединения с сервером" };
    }
}