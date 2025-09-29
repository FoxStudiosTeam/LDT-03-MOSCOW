'use client';

import { Header } from "@/app/components/header";
import { useProjectStore } from "@/storage/projectStorage";
import { useParams } from "next/navigation";
import { useState } from "react";
import Image from "next/image";
import Link from "next/link";


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
                                    className="bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md"
                                >
                                    Вернуться
                                </button>
                            </div>

                            <div className="flex flex-wrap gap-3">
                                {projectData?.attachments.map((item, itemIdx) => (
                                    <div key={itemIdx} className="max-w-[80px] max-h-[70px] cursor-pointer">
                                        <Link href={`https://test.foxstudios.ru:32460/Vadim/api/attachmentproxy/file?file_id=${item.uuid}`}>
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
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-xl font-semibold">Ваши объекты</h1>
                </div>

                <div className="flex justify-between gap-4 mb-6">
                    <button onClick={() => setIsModalWindowOpen(true)} className="bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                        Вложения
                    </button>

                    <button className="bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                        Список предписаний
                    </button>
                </div>

                <div className="space-y-4">
                    {/* {projectData.coordinates && (
                        <p>
                            Координаты: X: {projectData.coordinates.x}, Y:{" "}
                            {projectData.coordinates.y}, Z: {projectData.coordinates.z}
                        </p>
                    )} */}
                    {projectData ? (
                        <div className="border rounded-md p-4 bg-white shadow-sm">
                            <div className="flex justify-between items-center cursor-pointer">
                                <div>
                                    <p className="font-medium">{projectData.project.address}</p>
                                    <p className="text-sm text-gray-600">
                                        Статус: {projectData.project.status}
                                    </p>
                                </div>
                            </div>
                            <div className="mt-4 space-y-2 text-sm">
                                {projectData.project.customer && <p>Заказчик: {projectData.project.customer}</p>}
                                {projectData.project.contractor ? (
                                    <p>Подрядчик: {projectData.project.contractor}</p>
                                ) : (
                                    <p>Подрядчик отсутствует</p>
                                )}
                                {projectData.project.inspector && <p>Ответственный инспектор: {projectData.project.inspector}</p>}
                                {projectData.project.start_date && <p>Дата начала: {projectData.project.start_date}</p>}
                                {projectData.project.end_date && <p>Дата конца: {projectData.project.end_date}</p>}
                            </div>
                        </div>
                    ) : (
                        <p>Загрузка данных...</p>
                    )}

                    <div className="w-full justify-end flex flex-col gap-4 mb-6">
                        <button className="min-w-[250px] self-end bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                            Отчеты
                        </button>

                        <button className="min-w-[250px] self-end bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                            Материалы
                        </button>

                        <button className="min-w-[250px] self-end bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                            График работ
                        </button>

                        <button className="min-w-[250px] self-end bg-red-700 hover:bg-red-800 text-white px-4 py-2 rounded-md">
                            Прикрепить документы
                        </button>
                    </div>
                </div>
            </main>
        </div>

    )
}