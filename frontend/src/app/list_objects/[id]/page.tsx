'use client';

import { Header } from "@/app/components/header";
import { useProjectStore } from "@/storage/projectStorage";
import { useParams } from "next/navigation";
import { useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { ProjectMap } from "@/app/components/map";
import styles from "@/app/styles/variables.module.css"


export default function ObjectDetail() {
    const params = useParams();

    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);

    const projectData = useProjectStore((state) => {
        if (!params?.id) return undefined;
        return state.getProjectById(params.id as string);
    });

    const hydrated = useProjectStore((state) => state.hydrated);

    if (!hydrated) {
        return <p>Загрузка данных...</p>;
    }


    return (
        <div className="relative flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[60%] bg-white px-8 pt-2">
                {isModalWindowOpen ? (
                    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/50">
                        <div className="w-full flex flex-col max-w-[1200px] min-h-[500px] bg-white px-4 py-5 sm:px-6 md:px-8 rounded-lg shadow-lg z-50">
                            <div className="flex justify-end mb-4">
                                <button
                                    onClick={() => setIsModalWindowOpen(false)}
                                    className={styles.mainButton}
                                >
                                    Вернуться
                                </button>
                            </div>

                            <div className="flex flex-wrap gap-3">
                                {projectData?.attachments.map((item, itemIdx) => (
                                    <div key={itemIdx} className="max-w-[80px] max-h-[70px] cursor-pointer">
                                        <Link href={`https://test.foxstudios.ru:32460/api/attachmentproxy/file?file_id=${item.uuid}`}>
                                            <Image
                                                src={'/attachment/attachment.svg'}
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
                        href={'/list_objects'}
                        className="flex flex-row gap-2 items-center"
                    >
                        <Image src={'/backArrow.svg'} alt="Вернуться на главную страницу" height={15} width={30} />
                        <span>Вернуться</span>
                    </Link>
                </div>

                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-xl font-semibold">Ваши объекты</h1>
                </div>

                <div className="flex justify-between gap-4 mb-6">
                    <button onClick={() => setIsModalWindowOpen(true)} className={styles.mainButton}>
                        Вложения
                    </button>

                    <button className={styles.mainButton}>
                        Список предписаний
                    </button>
                </div>

                <div className="space-y-4">
                    {projectData ? (
                        <div className=" p-4 bg-white shadow-sm">
                            <div className="flex justify-between items-center cursor-pointer">
                                <div className="mb-2 flex flex-col gap-3">
                                    <p className="font-medium">{projectData.project.address}</p>
                                    <p className="text-sm text-gray-600">
                                        Статус: {projectData.project.status}
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
                                        {projectData.project.customer || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Подрядчик:</p>
                                    <p className="border-b border-[#D0D0D0]">
                                        {projectData.project.contractor || "отсутствует"}
                                    </p>
                                </div>

                                <div className="grid grid-cols-[120px_1fr] gap-2">
                                    <p className="text-gray-700">Инспектор:</p>
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

                    <div className="w-full justify-end flex flex-col gap-4 mb-6">
                        <button
                            className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            Отчеты
                        </button>

                        <button
                            className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            Материалы
                        </button>

                        <button
                            className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            График работ
                        </button>

                        <button
                            className={`self-end min-w-[250px] ${styles.mainButton}`}>
                            Прикрепить документы
                        </button>
                    </div>
                </div>
            </main>
        </div>

    )
}