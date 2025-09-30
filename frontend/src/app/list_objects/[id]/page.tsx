"use client";

import { Header } from "@/app/components/header";
import { useProjectStore } from "@/storage/projectStorage";
import { useParams } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ProjectMap } from "@/app/components/map";
import styles from "@/app/styles/variables.module.css";
import {GetStatuses, uploadProjectFiles} from "@/app/Api/Api";
import { Status } from "@/models";

export default function ObjectDetail() {
    const params = useParams();

    const [statuses, setStatuses] = useState<Status[]>([]);
    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);
    const fileInputRef = useRef<HTMLInputElement | null>(null);

    useEffect(() => {
        const loadStatuses = async () => {
            const data = await GetStatuses();
            if (data.success) {
                setStatuses(data.result);
            } else {
                console.error("Ошибка при загрузке статусов:", data.message);
            }
        };
        loadStatuses();
    }, []);

    const getStatusTitle = (statusId: number) => {
        const status = statuses.find((s) => s.id === statusId);
        return status ? status.title : "Неизвестно";
    };

    const projectData = useProjectStore((state) => {
        if (!params?.id) return undefined;
        localStorage.setItem("projectUuid", params.id as string);
        return state.getProjectById(params.id as string);
    });

    const hydrated = useProjectStore((state) => state.hydrated);

    const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
        if (!e.target.files || !params?.id) return;

        const { uploaded, errors } = await uploadProjectFiles(params.id as string, e.target.files);

        if (uploaded.length) {
            console.log("Файлы успешно загружены:", uploaded);
        }
        if (errors.length) {
            console.error("Ошибки при загрузке файлов:", errors);
        }

        e.target.value = "";
    };

    if (!hydrated) {
        return <p>Загрузка данных...</p>;
    }

    return (
        <div className="relative flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className=" w-full max-w-[1200px] bg-white px-8 pt-2">
                {isModalWindowOpen ? (
                    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/50">
                        <div
                            className="w-full flex flex-col max-w-[1200px] min-h-[500px] bg-white px-4 py-5 sm:px-6 md:px-8 rounded-lg shadow-lg z-50">
                            <div className="flex justify-start mb-4 min-w-[250px]">
                                <button
                                    onClick={() => setIsModalWindowOpen(false)}
                                    className={styles.mainButton}
                                >
                                    Вернуться
                                </button>
                            </div>
                            <p className="text-gray-700 mb-3">Если файлы не появляются перейдите на страницу &#34;Список объектов&#34; и попробуйте снова</p>
                            <div className="flex flex-wrap gap-3">
                                {projectData?.attachments.map((item, itemIdx) => (
                                    <div
                                        key={itemIdx}
                                        className="max-w-[80px] max-h-[70px] cursor-pointer"
                                    >
                                        <Link
                                            href={`https://test.foxstudios.ru:32460/api/attachmentproxy/file?file_id=${item.uuid}`}
                                        >
                                            <Image
                                                src={"/attachment/attachment.svg"}
                                                alt="Скачать вложение"
                                                width={50}
                                                height={50}
                                                className="mx-auto"
                                            />
                                            <p className="break-words text-ballance text-center text-sm">
                                                {item.original_filename}
                                            </p>
                                        </Link>
                                    </div>
                                ))}
                            </div>
                        </div>
                    </div>
                ) : null}

                <div className="mb-6">
                    <Link
                        href={"/list_objects"}
                        className="flex flex-row gap-2 items-center"
                    >
                        <Image
                            src={"/backArrow.svg"}
                            alt="Вернуться на главную страницу"
                            height={15}
                            width={30}
                        />
                        <span>Вернуться</span>
                    </Link>
                </div>

                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-xl font-semibold">Ваши объекты</h1>
                </div>

                <div className="flex justify-between gap-4 mb-6">
                    <button
                        onClick={() => setIsModalWindowOpen(true)}
                        className={`min-w-[250px] ${styles.mainButton}`}
                    >
                        Вложения
                    </button>

                    <button className={`min-w-[250px] ${styles.mainButton}`}>
                        Список предписаний
                    </button>
                </div>

                <div className="space-y-4">
                    {projectData ? (
                        <div className="p-4 bg-white shadow-sm">
                            <div className="flex justify-between items-center cursor-pointer">
                                <div className="mb-4 flex flex-col gap-3">
                                    <p className="font-medium">
                                        {projectData.project.address}
                                    </p>
                                    <p className="text-sm text-gray-600">
                                        Статус: {getStatusTitle(projectData.project.status)}
                                    </p>
                                </div>
                            </div>

                            {projectData.project.polygon ? (
                                <ProjectMap polygon={projectData.project.polygon} />
                            ) : (
                                <p>Карта: нет данных</p>
                            )}
                            <div className="flex flex-col gap-3 w-1/4 mt-4 space-y-2 text-sm">
                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Заказчик:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.created_by || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Подрядчик:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.foreman || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Инспекторы:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.inspector || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Дата начала:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.start_date || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Дата конца:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.end_date || "отсутствует"}
                                    </p>
                                </div>
                            </div>
                        </div>
                    ) : (
                        <p>Загрузка данных...</p>
                    )}

                    <div className="w-full justify-end flex flex-col gap-4 mb-6 text-center">
                        <Link href={"/reports"} className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            Отчеты
                        </Link>

                        <button className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            Материалы
                        </button>

                        <Link href={"/gant/"} className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            График работ
                        </Link>

                        <div className="w-full flex items-center gap-4">
                            {projectData?.project.status === 0 && (
                                <Link
                                    href={"/activation/"}
                                    className={`min-w-[250px] ${styles.mainButton}`}
                                >
                                    Активация
                                </Link>
                            )}

                            <button
                                onClick={() => fileInputRef.current?.click()}
                                className={`min-w-[250px] ml-auto ${styles.mainButton}`}
                            >
                                Прикрепить документы
                            </button>

                            <input
                                ref={fileInputRef}
                                type="file"
                                accept=".pdf,.jpg,.jpeg,.png,.gif,.doc,.docx"
                                multiple
                                className="hidden"
                                onChange={handleFileChange}
                            />
                        </div>

                    </div>
                </div>
            </main>
        </div>
    );
}
