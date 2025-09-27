"use client"

import {jwtDecode} from "jwt-decode";

const baseURL = "https://test.foxstudios.ru:32460/api";

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

export async function CreateObject(address: string, polygon: string, ssk: string) {
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
            body: JSON.stringify({ address, polygon, ssk })
        });

        if (!response.ok) {
            throw new Error(`Ошибка: ${response.status} ${response.statusText}`);
        }

        const result = await response.json();
        return { success: true, message: null, result: result.uuid };

    } catch (error) {
        console.error("Ошибка создания объекта:", error);
        return { success: false, message: String(error) };
    }
}
