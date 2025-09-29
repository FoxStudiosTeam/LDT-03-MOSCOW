'use client';

import { Header } from "@/app/components/header";

import { useEffect, useState } from "react";
import React from "react";
import Link from "next/link";
import Image from "next/image";
import styles from "@/app/styles/variables.module.css";
import { GetReports } from "@/app/Api/Api";

type Order = {
    id: number;
    reportDate: string;
    checkDate: string;
    status: string;
};


export default function Orders() {
    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);
    const [reports, setReports] = useState<Order>();


    useEffect(() => {
        const getReports = async () => {
            const projectId = localStorage.getItem("projectUuid");
            if (projectId) {
                const response = await GetReports(projectId);
                setReports(response.result)
            }
        }

        getReports();
    }, []);

    console.log(reports)

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            {isModalWindowOpen ? (
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
                        {reports.map((order) => (
                            <tr key={order.id} className="hover:bg-gray-50">
                                <td className="border px-4 py-2">{order.id}</td>
                                <td className="border px-4 py-2">{order.reportDate}</td>
                                <td className="border px-4 py-2">{order.checkDate}</td>
                                <td className="border px-4 py-2">{order.status}</td>
                                <td className="border px-4 py-2 text-center">
                                    <button className="cursor-pointer">
                                        <Image
                                            src="/Tables/download.svg"
                                            alt="download"
                                            width={20}
                                            height={20}
                                        />
                                    </button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </main>
        </div>
    );
}
