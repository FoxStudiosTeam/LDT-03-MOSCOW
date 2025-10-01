"use client";

import { Header } from "@/app/components/header";
import { useProjectStore } from "@/storage/projectStorage";
import { useParams } from "next/navigation";
import Image from "next/image";
import Link from "next/link";
import { useEffect, useState } from "react";
import styles from "@/app/styles/variables.module.css"
import { Attachment, Status } from "@/models";
import { GetPunishmetStatuses } from "@/app/Api/Api";
import { useAuthRedirect } from "@/lib/hooks/useAuthRedirect";

export default function PunishmentPage() {
    const isReady = useAuthRedirect();
    const params = useParams();
    const id = Array.isArray(params.id) ? params.id[0] : params.id;
    const PunishmentItem = useProjectStore((state) => state.getPunishments());
    const hydrated = useProjectStore((state) => state.hydrated);

    const [isModalWindowOpen, setIsModalWindowOpen] = useState(false);
    const [selectedAttachments, setSelectedAttachments] = useState<Attachment[]>([]);
    const [statuses, setStatuses] = useState<Status[]>([]);

    useEffect(() => {
        if (!isReady) return;
        const getStatuses = async () => {
            const response = await GetPunishmetStatuses();
            console.log('res', response)
            if (response) {
                setStatuses(response.result);
            }
        }

        getStatuses();
    }, [isReady])

    const getStatusTitle = (id: number) => {
        const status = statuses.find((s) => s.id === id);
        return status ? status.title : id;
    };

    if (!hydrated) {
        return <div className="flex justify-center items-center min-h-screen">Загрузка...</div>;
    }

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="w-[80%] bg-white px-8 py-6 flex flex-col items-center gap-6">
                {isModalWindowOpen && (
                    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/50">
                        <div
                            className="w-full flex flex-col max-w-[1200px] min-h-[500px] bg-white px-4 py-5 sm:px-6 md:px-8 rounded-lg shadow-lg z-50"
                        >
                            <div className="flex justify-start mb-4 min-w-[250px]">
                                <button
                                    onClick={() => setIsModalWindowOpen(false)}
                                    className={styles.mainButton}
                                >
                                    Вернуться
                                </button>
                            </div>
                            {selectedAttachments.length === 0 ? (
                                <p className="text-gray-500">Нет вложений</p>
                            ) : (
                                <div className="flex flex-wrap gap-3">
                                    {selectedAttachments.map((att, idx) => (
                                        <div
                                            key={idx}
                                            className="max-w-[80px] max-h-[70px] cursor-pointer"
                                        >
                                            <Link
                                                href={`https://test.foxstudios.ru:32460/api/attachmentproxy/file?file_id=${att.uuid}`}
                                            >
                                                <Image
                                                    src={"/attachment/attachment.svg"}
                                                    alt="Скачать вложение"
                                                    width={50}
                                                    height={50}
                                                    className="mx-auto"
                                                />
                                                <p className="break-words text-ballance text-center text-sm">
                                                    {att.original_filename}
                                                </p>
                                            </Link>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>
                )}

                <div className="self-start">
                    <Link
                        href={`/list_objects/${id}/punishment`}
                        className="flex flex-row gap-2 items-center"
                    >
                        <Image
                            src={"/backArrow.svg"}
                            alt="Вернуться"
                            height={15}
                            width={30}
                        />
                        <span>Вернуться</span>
                    </Link>
                </div>

                <div className="w-full flex flex-col sm:flex-row justify-between gap-2 sm:gap-0">
                    <p className="font-bold text-xl">Предписания</p>
                </div>

                {PunishmentItem.length === 0 ? (
                    <div className="w-full text-center py-10 text-gray-500">
                        Нет данных по предписаниям
                    </div>
                ) : (
                    <div className="w-full grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
                        {PunishmentItem.map((punishment, punishmentIdx) => (
                            <div
                                key={punishmentIdx}
                                onClick={() => {
                                    setSelectedAttachments(punishment.attachments || []);
                                    setIsModalWindowOpen(true);
                                }}
                                className="border border-[#D0D0D0] rounded-xl shadow-sm p-4 bg-gray-50 hover:shadow-md transition cursor-pointer flex flex-col gap-2"
                            >
                                <div className="flex justify-between items-center">
                                    <span className="text-sm font-semibold text-gray-600">
                                        № {punishmentIdx + 1}
                                    </span>
                                    <span className="text-xs text-gray-500">
                                        {punishment.punishment_item.punish_datetime}
                                    </span>
                                </div>

                                <p className="font-bold text-gray-800">
                                    {punishment.punishment_item.title}
                                </p>

                                <div className="text-sm text-gray-700">
                                    <p>
                                        <span className="font-semibold">Статус: </span>
                                        {getStatusTitle(punishment.punishment_item.punishment_item_status)}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Остановка работ: </span>
                                        {punishment.punishment_item.is_suspend ? "Да" : "Нет"}
                                    </p>
                                    <p>
                                        <span className="font-semibold">План устранения: </span>
                                        {punishment.punishment_item.correction_date_plan || "-"}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Факт устранения: </span>
                                        {punishment.punishment_item.correction_date_fact || "-"}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Перенос срока: </span>
                                        {punishment.punishment_item.correction_date_info || "-"}
                                    </p>
                                    <p>
                                        <span className="font-semibold">Примечание: </span>
                                        {punishment.punishment_item.comment || "-"}
                                    </p>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </main>
        </div>
    );
}
