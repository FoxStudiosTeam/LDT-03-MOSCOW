"use client"

import {jwtDecode} from "jwt-decode";

const baseURL = "https://sso.foxstudios.ru:32460";

interface TokenPayload {
    exp: number;
    uuid: string;
    role: string;
    org: string;
}

export async function AuthUser(login: string, password: string) {
    try {
        const response = await fetch(`${baseURL}/api/auth/session`, {
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
