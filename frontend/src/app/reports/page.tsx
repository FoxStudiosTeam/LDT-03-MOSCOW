'use client';

import { Header } from "@/app/components/header";
import React, { useState } from "react";
import Image from "next/image";

const reportsData = [
    { id: 1, reportDate: "01.01.2025", checkDate: "", status: "Нарушение" },
    { id: 2, reportDate: "01.01.2025", checkDate: "", status: "Выполнено" },
    { id: 3, reportDate: "01.01.2025", checkDate: "", status: "Нарушение" },
    { id: 4, reportDate: "01.01.2025", checkDate: "", status: "Выполнено" },
];

export default function Reports() {
    const [isOpen, setIsOpen] = useState(false);
    const [images, setImages] = useState<string[]>([]);
    const [loading, setLoading] = useState(false);

    const openModal = async (reportId: number) => {
        setLoading(true);
        setIsOpen(true);

        try {
            const res = await fetch(`http://localhost:8080/api/reports/${reportId}/images`);
            const data = await res.json();

            setImages(data);
        } catch (e) {
            console.error("Ошибка загрузки картинок:", e);
            setImages([]);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6">
                <table className="w-full border-collapse text-left">
                    <thead>
                    <tr className="bg-gray-100">
                        <th className="border px-4 py-2">Код</th>
                        <th className="border px-4 py-2">Дата отчета</th>
                        <th className="border px-4 py-2">Дата проверки</th>
                        <th className="border px-4 py-2">Статус</th>
                        <th className="border px-4 py-2"></th>
                    </tr>
                    </thead>
                    <tbody>
                    {reportsData.map((report) => (
                        <tr key={report.id} className="hover:bg-gray-50">
                            <td className="border px-4 py-2">{report.id}</td>
                            <td className="border px-4 py-2">{report.reportDate}</td>
                            <td className="border px-4 py-2">{report.checkDate}</td>
                            <td className="border px-4 py-2">{report.status}</td>
                            <td className="border px-4 py-2 text-center">
                                <button onClick={() => openModal(report.id)}>
                                    <Image
                                        src="/Tables/photos.svg"
                                        alt="open images"
                                        width={24}
                                        height={24}
                                    />
                                </button>
                            </td>
                        </tr>
                    ))}
                    </tbody>
                </table>

                {isOpen && (
                    <div className="fixed inset-0 bg-black bg-opacity-70 flex justify-center items-center z-50">
                        <div className="bg-white p-6 rounded-xl w-[80%] max-h-[80%] overflow-y-auto relative">
                            <button
                                onClick={() => setIsOpen(false)}
                                className="absolute top-3 right-3 text-2xl font-bold text-gray-700 hover:text-black"
                            >
                                ✕
                            </button>

                            <h2 className="text-xl font-semibold mb-4">Фотографии отчёта</h2>

                            {loading ? (
                                <p>Загрузка...</p>
                            ) : images.length > 0 ? (
                                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
                                    {images.map((img, idx) => (
                                        <div key={idx} className="relative w-full h-40">
                                            <Image
                                                src={img}
                                                alt={`report image ${idx}`}
                                                fill
                                                className="object-cover rounded"
                                            />
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <p>Нет загруженных изображений</p>
                            )}
                        </div>
                    </div>
                )}
            </main>
        </div>
    );
}
