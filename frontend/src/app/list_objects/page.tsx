"use client";

import { useState, useEffect } from "react";
import { Header } from "@/app/components/header";
import Link from "next/link";
import { GetProjects, GetStatuses } from "@/app/Api/Api";
import { useProjectStore } from "@/storage/projectStorage";
import { ProjectMap } from "@/app/components/map";
import { Status } from "@/models";
import { useUserStore } from "@/storage/userstore";

interface Attachment {
    base_entity_uuid: string;
    content_type: string | null;
    file_uuid: string;
    original_filename: string;
    uuid: string;
}

interface ProjectData {
    uuid: string;
    address: string | null;
    status: number;
    ssk: string | null;
    foreman: string | null;
    created_by: string | null;
    start_date: string | null;
    end_date: string | null;
    polygon: string | null;
    attachments: Attachment[];
}

export default function ProjectsPage() {
    const userData = useUserStore((state) => state.userData);
    const [statuses, setStatuses] = useState<Status[]>([]);
    const [openProject, setOpenProject] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);

    const [userRole, setUserRole] = useState<string | null>(null);

    useEffect(() => {
        if (!userData) return;
        setUserRole(userData?.role);
    }, [userData])


    const limit = 5;

    const { projects, total, setProjects, clearProjects } = useProjectStore();

    const [totalPages, setTotalPages] = useState<number>(0);
    const [currentPage, setCurrentPage] = useState<number>(1);
    const [currentPageContent, setCurrentPageContent] = useState<ProjectData[]>([]);

    const toggleProject = (uuid: string) => {
        setOpenProject(openProject === uuid ? null : uuid);
    };

    useEffect(() => {
        const loadProjects = async () => {
            setLoading(true);
            clearProjects();

            const data = await GetProjects((currentPage - 1) * limit, limit);

            if (data.success && Array.isArray(data.result) && data.result.length > 0) {
                setProjects(data.result, data.total);
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
    }, [currentPage, clearProjects, setProjects]);

    useEffect(() => {
        const totalPages = Math.ceil(total / limit);
        setTotalPages(totalPages);
    }, [total]);

    useEffect(() => {
        setCurrentPageContent(
            projects.map((p) => ({
                uuid: p.project.uuid,
                address: p.project.address,
                status: p.project.status,
                ssk: p.project.ssk,
                foreman: p.project.foreman,
                created_by: p.project.created_by,
                start_date: p.project.start_date,
                end_date: p.project.end_date,
                polygon: p.project.polygon,
                attachments: (p.attachments ?? []) as Attachment[],
            }))
        );
    }, [projects, currentPage, total]);

    const getStatusTitle = (statusId: number) => {
        const status = statuses.find((s) => s.id === statusId);
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
                    {userRole === 'customer' ? (
                        <Link
                            className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition"
                            href={"/list_objects/create_object/first_step/"}
                        >
                            Создать новый
                        </Link>

                    ) : null}

                    {userRole === 'inspector' ? (
                        <div className="w-full flex flex-row justify-center gap-19">
                            <Link
                                className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition"
                                href={"/list_objects/create_object/first_step/"}
                            >
                                Мои объекты
                            </Link>

                            <Link
                                className="bg-red-700 text-white px-4 py-2 rounded-md hover:bg-red-800 transition"
                                href={"/list_objects/create_object/first_step/"}
                            >
                                Все объекты
                            </Link>
                        </div>
                    ) : null}
                </div>

                {loading && <p className="text-center text-gray-600">Загрузка проектов...</p>}

                <div className="space-y-4">
                    {currentPageContent &&
                        currentPageContent.map((project) => (
                            <div
                                key={project.uuid}
                                className="border rounded-md p-4 bg-white shadow-md hover:shadow-lg transition border-[#D0D0D0]"
                            >
                                <div
                                    className="flex justify-between items-center cursor-pointer"
                                    onClick={() => toggleProject(project.uuid)}
                                >
                                    <div>
                                        <Link
                                            href={`/list_objects/${project.uuid}`}
                                            className="font-medium text-blue-500 hover:text-blue-700 hover:underline decoration-1 underline-offset-2 transition-colors duration-200"
                                            onClick={(e) => {
                                                e.stopPropagation();
                                            }}
                                        >
                                            {project.address || "Адрес не указан"}
                                        </Link>


                                        <p className="text-sm text-gray-600">
                                            Статус: {getStatusTitle(project.status)}
                                        </p>
                                    </div>
                                    <span className="text-xl">
                                        {openProject === project.uuid ? "▲" : "▼"}
                                    </span>
                                </div>

                                {openProject === project.uuid && (
                                    <div className="mt-4 space-y-2 text-sm text-gray-700">
                                        <p>Подрядчик: {project.foreman || "не указан"}</p>

                                        {project.polygon ? (
                                            <ProjectMap polygon={project.polygon} />
                                        ) : (
                                            <p>Карта: нет данных</p>
                                        )}
                                    </div>
                                )}

                            </div>
                        ))}
                </div>

                <div className="flex justify-center mt-6 gap-2">
                    <button
                        disabled={currentPage === 1}
                        className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 disabled:opacity-50"
                        onClick={() => setCurrentPage(prev => prev - 1)}
                    >
                        Назад
                    </button>

                    <div className="px-4 py-2 bg-gray-300 rounded disabled:opacity-50">
                        {currentPage}
                    </div>

                    <span className="my-auto">ИЗ</span>

                    <div className="px-4 py-2 bg-gray-300 rounded disabled:opacity-50">
                        {totalPages}
                    </div>


                    <button
                        disabled={currentPage >= totalPages}
                        className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 disabled:opacity-50"
                        onClick={() => setCurrentPage(prev => prev + 1)}
                    >
                        Вперед
                    </button>
                </div>
            </main>
        </div>
    );
}
