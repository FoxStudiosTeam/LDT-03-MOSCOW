'use client';

import { Header } from "@/app/components/header";
import { useEffect, useState } from "react";
import React from "react";
import Link from "next/link";
import Image from "next/image";
import styles from "@/app/styles/variables.module.css";
import { GetReports } from "@/app/Api/Api";
import { ReportItem } from "@/models";

export default function Orders() {
    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);
    const [reports, setReports] = useState<ReportItem[]>([]);
    const [projectId, setProjectId] = useState<string | null>(null);
    const [selectedReport, setSelectedReport] = useState<ReportItem | null>(null);

    useEffect(() => {
        if (typeof window !== "undefined") {
            const storedId = localStorage.getItem("projectUuid");
            setProjectId(storedId);
        }
    }, []);

    useEffect(() => {
        const loadStatuses = async () => {
            if (!projectId) return;
            const data = await GetReports(projectId);
            if (!data) return;
            if (data.success) {
                setReports(data.result || []);
            } else {
                console.error("Ошибка при загрузке статусов:", data.message);
            }
        };
        loadStatuses();
    }, [projectId]);

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />

            {isModalWindowOpen && selectedReport && (
                <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/50">
                    <div className="w-full flex flex-col max-w-[1200px] min-h-[500px] bg-white px-4 py-5 sm:px-6 md:px-8 rounded-lg shadow-lg z-50">
                        <div className="flex justify-start mb-4 min-w-[250px]">
                            <button
                                onClick={() => setIsModalWindowOpen(false)}
                                className={styles.mainButton}
                            >
                                Вернуться
                            </button>
                        </div>

                        <div className="flex flex-wrap gap-3">
                            {selectedReport.attachments.length > 0 ? (
                                selectedReport.attachments.map((item, idx) => (
                                    <div
                                        key={idx}
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
                                            <p className="break-words text-center text-sm">
                                                {item.original_filename}
                                            </p>
                                        </Link>
                                    </div>
                                ))
                            ) : (
                                <p className="text-gray-500">Вложений нет</p>
                            )}
                        </div>
                    </div>
                </div>
            )}

            <main className="w-[80%] bg-white px-8 py-6 ">
                <div className="overflow-x-scroll">

                    <table className="w-full border-collapse text-left">
                        <thead>
                            <tr className="bg-gray-100">
                                <th className="border px-4 py-2">Код</th>
                                <th className="border px-4 py-2">Дата отчета</th>
                                <th className="border px-4 py-2">Дата проверки</th>
                                <th className="border px-4 py-2">Статус</th>
                                <th className="border px-4 py-2">Вложения</th>
                            </tr>
                        </thead>
                        <tbody>
                            {reports.map((item, idx) => (
                                <tr key={idx} className="hover:bg-gray-50">
                                    <td className="border px-4 py-2">{idx + 1}</td>
                                    <td className="border px-4 py-2">{item.report.report_date ? <p>{item.report.report_date}</p> : <p>-</p>}</td>
                                    <td className="border px-4 py-2">{item.report.check_date ? <p>{item.report.check_date}</p> : <p>-</p>}</td>
                                    <td className="border px-4 py-2">{item.report.status ? <p>{item.report.status}</p> : <p>-</p>}</td>
                                    <td className="w-[40px] border px-4 py-2 text-center">
                                        <button
                                            onClick={() => {
                                                setSelectedReport(item);
                                                setIsModalWindowOpen(true);
                                            }}
                                            className="w-full cursor-pointer"
                                        >
                                            <Image
                                                className="mx-auto"
                                                src="/attachment/files.svg"
                                                alt="download"
                                                width={30}
                                                height={30}
                                            />
                                        </button>
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            </main>
        </div>
    );
}
