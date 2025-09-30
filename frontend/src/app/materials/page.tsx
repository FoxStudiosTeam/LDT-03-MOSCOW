'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import {GetMaterialsById, GetMeasurement, RequestResearch} from "../Api/Api";
import {Attachment, MaterialResponse, Measurement} from "@/models";

type Material = {
    uuid: string;
    title: string;
    volume: number;
    measurement: number;
    delivery_date: string;
    on_research: boolean;
    attachments: Attachment[];
};

export default function Materials() {
    const [materials, setMaterials] = useState<Material[]>([]);
    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);
    const [selectedAttachments, setSelectedAttachments] = useState<Attachment[]>([]);
    const [message, setMessage] = useState<string | null>(null);
    const [isSuccess, setIsSuccess] = useState<boolean>(true);
    const [measurement, setMeasurement] = useState<Measurement[]>([]);


    const uuid = typeof window !== "undefined" ? localStorage.getItem("projectUuid") : null;

    useEffect(() => {
        const loadData = async () => {
            if (!uuid) return;

            const { successMaterials, resultMaterials, messageMaterials } = await GetMaterialsById(uuid);

            if (successMaterials && Array.isArray(resultMaterials)) {
                const mapped: Material[] = resultMaterials.map((item: MaterialResponse) => ({
                    uuid: item.material.uuid,
                    title: item.material.title,
                    volume: item.material.volume,
                    measurement: item.material.measurement, // пока храню id
                    delivery_date: item.material.delivery_date,
                    on_research: item.material.on_research,
                    attachments: item.attachments || [],
                }));
                setMaterials(mapped);
                setMessage(null);
            } else {
                setMessage(messageMaterials ?? "Не удалось загрузить материалы");
                setIsSuccess(false);
            }

            const { successMeasurement, messageMeasurement, resultMeasurement } = await GetMeasurement();
            if (successMeasurement && resultMeasurement) {
                setMeasurement(resultMeasurement);
            } else {
                setMessage(messageMeasurement || "Ошибка загрузки единиц измерения");
                setIsSuccess(false);
            }
        };

        loadData();
    }, [uuid]);


    const handleResearchRequest = async (id: string) => {
        const { success, message } = await RequestResearch(id);

        if (success) {
            setMaterials((prev) =>
                prev.map((m) =>
                    m.uuid === id ? { ...m, on_research: true } : m
                )
            );
            setMessage(message);
            setIsSuccess(true);
        } else {
            setMessage(message);
            setIsSuccess(false);
        }
    };

    const openAttachmentsModal = (attachments: Attachment[]) => {
        setSelectedAttachments(attachments);
        setIsModalWindowOpen(true);
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6 flex flex-col items-center gap-4">
                <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                    <p className="font-bold">Материалы</p>
                </div>

                <table className="w-full border-collapse text-left">
                    <thead>
                    <tr className="bg-gray-100">
                        <th className="border px-4 py-2">Название</th>
                        <th className="border px-4 py-2">Объем</th>
                        <th className="border px-4 py-2">Единицы измерения</th>
                        <th className="border px-4 py-2">Дата поставки</th>
                        <th className="border px-4 py-2">Документы</th>
                        <th className="border px-4 py-2"></th>
                    </tr>
                    </thead>
                    <tbody>
                    {materials.map((m) => (
                        <tr key={m.uuid} className="hover:bg-gray-50">
                            <td className="border px-4 py-2">{m.title}</td>
                            <td className="border px-4 py-2">{m.volume}</td>
                            <td className="border px-4 py-2">
                                {measurement.find((meas) => meas.id === m.measurement)?.title || m.measurement}
                            </td>
                            <td className="border px-4 py-2">{m.delivery_date}</td>
                            <td className="border px-4 py-2">
                                <button
                                    onClick={() => openAttachmentsModal(m.attachments)}
                                    className="flex items-center gap-1 text-blue-600 hover:text-blue-800"
                                >
                                    <Image
                                        src="/Tables/docs.svg"
                                        alt="Вложения"
                                        width={20}
                                        height={20}
                                    />
                                    <span>Вложения</span>
                                </button>
                            </td>
                            <td className="border px-4 py-2 text-right">
                                {!m.on_research ? (
                                    <button
                                        onClick={() => handleResearchRequest(m.uuid)}
                                        className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
                                    >
                                        Запросить исследование
                                    </button>
                                ) : (
                                    <span className="text-gray-600 font-semibold">
                                            Идёт исследование...
                                        </span>
                                )}
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>

                {message && (
                    <p
                        className={`w-full text-center pt-2 ${
                            isSuccess ? "text-green-600" : "text-red-600"
                        }`}
                    >
                        {message}
                    </p>
                )}

                {isModalWindowOpen && (
                    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/50">
                        <div className="w-full flex flex-col max-w-[1200px] min-h-[500px] bg-white px-4 py-5 sm:px-6 md:px-8 rounded-lg shadow-lg z-50">
                            <div className="flex justify-start mb-4 min-w-[250px]">
                                <button
                                    onClick={() => setIsModalWindowOpen(false)}
                                    className="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700"
                                >
                                    Вернуться
                                </button>
                            </div>
                            <div className="flex flex-wrap gap-3">
                                {selectedAttachments.map((item, idx) => (
                                    <div key={idx} className="max-w-[80px] max-h-[70px] cursor-pointer">
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
                )}
            </main>
        </div>
    );
}
