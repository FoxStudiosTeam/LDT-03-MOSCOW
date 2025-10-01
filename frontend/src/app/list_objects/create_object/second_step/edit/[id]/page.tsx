'use client';

import { Header } from "@/app/components/header";
import { useParams, useRouter } from "next/navigation";
import { useActionsStore } from "@/storage/jobsStorage";
import React, { useEffect, useRef, useState } from "react";
import Image from "next/image";
import { Measurement, SubJob, WorkItem } from "@/models";
import { GetMeasurement, UpdateWorksInSchedule } from "@/app/Api/Api";
import { useAuthRedirect } from "@/lib/hooks/useAuthRedirect";


export default function EditSubjobs() {
    useAuthRedirect();
    
    const { id } = useParams<{ id: string }>();
    const router = useRouter();
    const { data } = useActionsStore();

    const block = data.find(b => b.uuid === id);

    const [tableData, setTableData] = useState<SubJob[]>([]);
    const [measurement, setMeasurement] = useState<Measurement[]>([]);
    const [editingCell, setEditingCell] = useState<{ row: number; col: keyof SubJob } | null>(null);
    const inputRef = useRef<HTMLInputElement | HTMLTextAreaElement | null>(null);
    const [messages, setMessages] = useState<string[]>([]);
    const [isSubmitting, setIsSubmitting] = useState(false);

    useEffect(() => {
        if (block) {
            const mapped = (block.items ?? []).map(i => ({
                title: i.title,
                volume: i.target_volume,
                unitOfMeasurement: i.measurement !== null && i.measurement !== undefined ? String(i.measurement) : "",
                startDate: i.start_date,
                endDate: i.end_date,
            }));
            setTableData(mapped);
        }
    }, [block]);


    useEffect(() => {
        const getData = async () => {
            const msgs: string[] = [];

            const { successMeasurement, messageMeasurement, resultMeasurement } = await GetMeasurement();
            if (successMeasurement) {
                setMeasurement(resultMeasurement);
            } else {
                msgs.push(messageMeasurement || "Ошибка загрузки единиц измерения");
            }

            setMessages(msgs);
        };
        getData();
    }, []);

    useEffect(() => {
        if (inputRef.current) {
            inputRef.current.focus();
            const val = (inputRef.current as HTMLInputElement | HTMLTextAreaElement).value ?? "";
            try {
                (inputRef.current as HTMLInputElement | HTMLTextAreaElement).setSelectionRange(val.length, val.length);
            } catch { }
        }
    }, [editingCell]);

    const startEdit = (rowIdx: number, colKey: keyof SubJob) => setEditingCell({ row: rowIdx, col: colKey });
    const stopEdit = () => setEditingCell(null);

    const updateCell = (rowIdx: number, colKey: keyof SubJob, value: string) => {
        setTableData(prev => {
            const next = [...prev];
            const old = next[rowIdx];
            if (!old) return prev;

            if (colKey === "volume") {
                const num = value === "" ? 0 : Number(value);
                next[rowIdx] = { ...old, volume: Number.isFinite(num) ? num : 0 };
            } else if (colKey === "startDate") {
                const newStart = new Date(value).getTime();
                const end = old.endDate ? new Date(old.endDate).getTime() : null;

                if (end && newStart > end) {
                    setMessages(["Дата начала не может быть позже даты окончания"]);
                    return prev; // отмена
                }

                next[rowIdx] = { ...old, startDate: value };
            } else if (colKey === "endDate") {
                const newEnd = new Date(value).getTime();
                const start = old.startDate ? new Date(old.startDate).getTime() : null;

                if (start && newEnd < start) {
                    setMessages(["Дата окончания не может быть раньше даты начала"]);
                    return prev; // отмена
                }

                next[rowIdx] = { ...old, endDate: value };
            } else {
                next[rowIdx] = { ...old, [colKey]: value };
            }

            return next;
        });
    };


    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>) => {
        if (e.key === "Enter") {
            if ((e.target as HTMLTextAreaElement).tagName !== "TEXTAREA") e.preventDefault();
            stopEdit();
        }
        if (e.key === "Escape") stopEdit();
    };

    const addRow = () =>
        setTableData(prev => [
            ...prev,
            { title: "", volume: 0, unitOfMeasurement: "", startDate: "", endDate: "" },
        ]);
    const deleteRow = (idx: number) => {
        setTableData(prev => prev.filter((_, i) => i !== idx));
        if (editingCell?.row === idx) stopEdit();
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        if (!block) return;
        if (isSubmitting) return;
        setIsSubmitting(true);

        try {
            const items: WorkItem[] = tableData.map(row => ({
                end_date: row.endDate,
                is_complete: false,
                measurement: row.unitOfMeasurement ? Number(row.unitOfMeasurement) : undefined,
                start_date: row.startDate,
                target_volume: row.volume,
                title: row.title,
                uuid: null,
            }));

            const { success: successUpd, message: messageUpd } = await UpdateWorksInSchedule(items, block.uuid);
            if (!successUpd) {
                setMessages([messageUpd || "Ошибка при обновлении work-schedule"]);
                setIsSubmitting(false);
                return;
            }

            setMessages(["Этапы успешно сохранены"]);
            router.push('/list_objects/create_object/second_step/');

        } catch (err) {
            console.error("Ошибка при сохранении:", err);
            setMessages(["Непредвиденная ошибка"]);
        } finally {
            setIsSubmitting(false);
        }
    };

    if (!block) return <div>Этап не найден</div>;

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="min-h-[calc(100vh-50px)] w-[80%] bg-white px-[10%] flex flex-col items-center gap-4 ">
                <div className="w-full">
                    <p>Редактирование этапа: {block.title}</p>
                </div>
                <form onSubmit={handleSubmit} className="w-full flex flex-col gap-4">
                    <div className="w-full overflow-x-auto">
                        <table className="w-full table-fixed border-collapse">
                            <thead>
                                <tr className="bg-slate-100 text-left">
                                    <th className="px-4 py-3">Название работы</th>
                                    <th className="px-4 py-3 w-32">Объем</th>
                                    <th className="px-4 py-3">Единицы измерения</th>
                                    <th className="px-4 py-3">Дата начала</th>
                                    <th className="px-4 py-3">Дата окончания</th>
                                    <th className="px-4 py-3 w-[80px]"></th>
                                </tr>
                            </thead>
                            <tbody>
                                {tableData.map((item, itemIdx) => {
                                    const editing = editingCell?.row === itemIdx;
                                    return (
                                        <tr key={itemIdx} className="border-t border-slate-200 hover:bg-slate-50">
                                            <td onClick={() => startEdit(itemIdx, "title")}>
                                                {editing && editingCell?.col === "title" ? (
                                                    <textarea
                                                        ref={el => {
                                                            inputRef.current = el;
                                                        }}
                                                        value={item.title}
                                                        onChange={e => updateCell(itemIdx, "title", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-28 p-2 resize-y outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[48px]">{item.title || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "volume")}>
                                                {editing && editingCell?.col === "volume" ? (
                                                    <input
                                                        ref={el => {
                                                            inputRef.current = el;
                                                        }}
                                                        type="number"
                                                        value={item.volume}
                                                        onChange={e => updateCell(itemIdx, "volume", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.volume}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "unitOfMeasurement")}>
                                                {editing && editingCell?.col === "unitOfMeasurement" ? (
                                                    <select
                                                        value={item.unitOfMeasurement}
                                                        onChange={(e) => updateCell(itemIdx, "unitOfMeasurement", e.target.value)}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    >
                                                        <option value="" disabled>Выберите единицу</option>
                                                        {measurement.map((meas) => (
                                                            <option value={String(meas.id)} key={meas.id}>
                                                                {meas.title}
                                                            </option>
                                                        ))}
                                                    </select>
                                                ) : (
                                                    <div className="min-h-[36px]">
                                                        {measurement.find(m => String(m.id) === item.unitOfMeasurement)?.title || (
                                                            <span className="text-slate-400">—</span>
                                                        )}
                                                    </div>
                                                )}
                                            </td>

                                            <td onClick={() => startEdit(itemIdx, "startDate")}>
                                                {editing && editingCell?.col === "startDate" ? (
                                                    <input
                                                        ref={el => {
                                                            inputRef.current = el;
                                                        }}
                                                        type="date"
                                                        value={item.startDate}
                                                        onChange={e => updateCell(itemIdx, "startDate", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.startDate || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td onClick={() => startEdit(itemIdx, "endDate")}>
                                                {editing && editingCell?.col === "endDate" ? (
                                                    <input
                                                        ref={el => {
                                                            inputRef.current = el;
                                                        }}
                                                        type="date"
                                                        value={item.endDate}
                                                        onChange={e => updateCell(itemIdx, "endDate", e.target.value)}
                                                        onBlur={stopEdit}
                                                        onKeyDown={handleKeyDown}
                                                        className="w-full h-10 p-2 outline-none border rounded"
                                                    />
                                                ) : (
                                                    <div className="min-h-[36px]">{item.endDate || <span className="text-slate-400">—</span>}</div>
                                                )}
                                            </td>
                                            <td className="text-center align-middle">
                                                <button
                                                    type="button"
                                                    onClick={() => deleteRow(itemIdx)}
                                                    className="flex h-12 w-12 items-center justify-center hover:text-red-600"
                                                >
                                                    <Image alt="Удаление" src="/Tables/delete.svg" height={20} width={20} />
                                                </button>
                                            </td>
                                        </tr>
                                    );
                                })}
                            </tbody>
                        </table>
                    </div>

                    <div className="w-full flex items-center justify-between gap-4">
                        <button type="button" className="bg-red-700 text-white px-6 py-2 rounded-lg" onClick={addRow}>
                            Добавить строку
                        </button>
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className={`px-6 py-2 rounded-lg text-white ${isSubmitting ? "bg-gray-400 cursor-not-allowed" : "bg-red-700 hover:bg-red-800"
                                }`}
                        >
                            {isSubmitting ? "Сохранение..." : "Сохранить"}
                        </button>
                    </div>

                    {messages.length > 0 && (
                        <div className="w-full flex flex-col items-center gap-1 pt-2">
                            {messages.map((msg, idx) => (
                                <p
                                    key={idx}
                                    className={`text-sm ${msg.includes("успешно") ? "text-green-600" : "text-red-600"}`}
                                >
                                    {msg}
                                </p>
                            ))}
                        </div>
                    )}
                </form>
            </main>
        </div>
    );
}
