"use client";

import { useState, useEffect } from "react";
import { Header } from "@/app/components/header";
import Link from "next/link";
import { GetProjects, GetStatuses } from "@/app/Api/Api";

interface ProjectData {
    uuid: string;
    address: string | null;
    status: number;
    ssk: string | null;
    foreman: string | null;
    created_by: string | null;
    start_date: string | null;
    end_date: string | null;
}

interface Status {
    id: number;
    title: string;
}

export default function ProjectsPage() {
    const [projects, setProjects] = useState<ProjectData[]>([]);
    const [statuses, setStatuses] = useState<Status[]>([]);
    const [openProject, setOpenProject] = useState<string | null>(null);
    const [offset, setOffset] = useState(0);
    const limit = 10;
    const [total, setTotal] = useState(0);
    const [loading, setLoading] = useState(false);

    const toggleProject = (uuid: string) => {
        setOpenProject(openProject === uuid ? null : uuid);
    };

    useEffect(() => {
        const loadProjects = async () => {
            setLoading(true);
            const data = await GetProjects(offset, limit);
            if (data.success) {
                setProjects(data.result);
                setTotal(data.total);
            } else {
                console.error("Ошибка при загрузке проектов:", data.message);
            }
            setLoading(false);
        };

        const loadStatuses = async () => {
            const data = await GetStatuses();
            if (data.success) {
                setStatuses(data.result);
            } else {
                console.error("Ошибка при загрузке статусов:", data.message);
            }
        };

        loadProjects();
        loadStatuses();
    }, [offset]);

    const getStatusTitle = (statusId: number) => {
        const status = statuses.find(s => s.id === statusId);
        return status ? status.title : "Неизвестно";
    };

    return (
        <div className="min-h-screen flex flex-col bg-[#D0D0D0]">
            <Header />
            <main className="flex-1 w-full max-w-6xl mx-auto bg-white px-6 sm:px-8 py-6 sm:py-10">
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-2xl sm:text-3xl font-semibold">Ваши объекты</h1>
                </div>

                <div className="flex flex-wrap gap-3 mb-6">
                    <button className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition">
                        В процессе
                    </button>
                    <button className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition">
                        Завершенные
                    </button>
                    <Link
                        className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition"
                        href={"/list_objects/create_object/first_step/"}
                    >
                        Создать новый
                    </Link>
                </div>

                {loading && <p className="text-center text-gray-600">Загрузка проектов...</p>}

                <div className="space-y-4">
                    {projects.map(project => (
                        <div
                            key={project.uuid}
                            className="border rounded-md p-4 bg-white shadow-md hover:shadow-lg transition"
                        >
                            <div
                                className="flex justify-between items-center cursor-pointer"
                                onClick={() => toggleProject(project.uuid)}
                            >
                                <div>
                                    <p className="font-medium">{project.address || "Адрес не указан"}</p>
                                    <p className="text-sm text-gray-600">
                                        Статус: {getStatusTitle(project.status)}
                                    </p>
                                </div>
                                <span className="text-xl">{openProject === project.uuid ? "▲" : "▼"}</span>
                            </div>

                            {openProject === project.uuid && (
                                <div className="mt-4 space-y-2 text-sm text-gray-700">
                                    {project.ssk && <p>Заказчик: {project.ssk}</p>}
                                    {project.foreman && <p>Подрядчик: {project.foreman}</p>}
                                    {project.start_date && <p>Дата начала: {project.start_date}</p>}
                                    {project.end_date && <p>Дата окончания: {project.end_date}</p>}
                                </div>
                            )}
                        </div>
                    ))}
                </div>

                <div className="flex justify-center mt-6 gap-2">
                    <button
                        disabled={offset === 0}
                        className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 disabled:opacity-50"
                        onClick={() => setOffset(offset - limit)}
                    >
                        Назад
                    </button>

                    <button
                        disabled={offset + limit >= total}
                        className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 disabled:opacity-50"
                        onClick={() => setOffset(offset + limit)}
                    >
                        Вперед
                    </button>
                </div>
            </main>
        </div>
    );
}
