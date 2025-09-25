'use client';

import { Header } from "@/app/components/header";
import React, { useEffect, useRef, useState } from "react";
import { v4 as uuidv4 } from 'uuid';
import { useParams } from "next/navigation";
import { useRouter } from "next/navigation";
import { useActionsStore } from "@/storage/jobsStorage";

interface SubJob {
    id: string;
    title: string;
    volume: number;
    unitOfMeasurement: string;
    startDate: string;
    endDate: string;
}

export default function AddSubjobs() {
    const params = useParams();
    const router = useRouter()
    const id = params.id;

    const jobs = useActionsStore((state) => state.jobs);
    const updateJob = useActionsStore((state) => state.updateJob);

    const [startDate, setStartDate] = useState('');
    const [endDate, setEndDate] = useState('');

    const [tableData, setTableData] = useState<SubJob[]>([]);

    const [editingCell, setEditingCell] = useState<{ row: number; col: keyof SubJob } | null>(null);
    const inputRef = useRef<HTMLInputElement | HTMLTextAreaElement | null>(null);

    useEffect(() => {
        if (jobs[Number(id)]) {
            setStartDate(jobs[Number(id)].startDate);
            setEndDate(jobs[Number(id)].endDate);
            setTableData(jobs[Number(id)].subJobs || []);
        }
    }, [jobs, id]);

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
            } else {
                next[rowIdx] = { ...old, [colKey]: value };
            }
            return next;
        });
    };

    const handleKeyDown = (
        e: React.KeyboardEvent<HTMLInputElement | HTMLTextAreaElement>
    ) => {
        if (e.key === "Enter") {
            if ((e.target as HTMLTextAreaElement).tagName === "TEXTAREA") {
                if (e.ctrlKey || e.metaKey) stopEdit();
            } else {
                e.preventDefault();
                stopEdit();
            }
        }
        if (e.key === "Escape") stopEdit();
    };

    const addJob = () => {
        setTableData(prev => [
            ...prev,
            { id: uuidv4(), title: '', volume: 0, unitOfMeasurement: '', startDate: '', endDate: '' }
        ]);
    };

    const deleteRow = (idx: number) => {
        setTableData(prev => prev.filter((_, i) => i !== idx));
        if (editingCell && editingCell.row === idx) stopEdit();
    };

    const handleSave = () => {
        if (jobs[Number(id)]) {
            updateJob(jobs[Number(id)].id, {
                startDate,
                endDate,
                subJobs: tableData
            });
        }
        router.push('/list_objects/create_object/second_step');
    };

    return (
        <div className="flex justify-center bg-[#D0D0D0] mt-[50px]">
            <Header />
            <main className="min-h-[calc(100vh-50px)] w-[80%] bg-white px-[10%] flex flex-col items-center gap-4 ">
                <div className="w-full">
                    <p>Добавить этап работы</p>
                </div>

                <div className="w-full flex flex-col gap-4">
                    <div className="flex flex-row justify-between gap-14">
                        <div className="w-full flex flex-col">
                            <label>Дата начала</label>
                            <input
                                value={startDate}
                                onChange={(e) => setStartDate(e.target.value)}
                                type="text"
                                placeholder="dd.mm.yyyy"
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                        <div className="w-full flex flex-col">
                            <label>Дата окончание</label>
                            <input
                                value={endDate}
                                onChange={(e) => setEndDate(e.target.value)}
                                type="text"
                                placeholder="dd.mm.yyyy"
                                className="w-full h-[36px] border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                    </div>
                </div>

                <div className="w-full overflow-x-auto">
                    <table className="w-full table-fixed border-collapse">
                        <thead>
                            <tr className="bg-slate-100 text-left">
                                <th className="px-4 py-3">Наименование работы</th>
                                <th className="px-4 py-3 w-32">Объем</th>
                                <th className="px-4 py-3">Единицы измерений</th>
                                <th className="px-4 py-3">Дата начала</th>
                                <th className="px-4 py-3">Дата окончание</th>
                                <th className="px-4 py-3 w-[80px]"></th>
                            </tr>
                        </thead>
                        <tbody>
                            {tableData.map((item, idx) => {
                                const editing = editingCell && editingCell.row === idx;
                                return (
                                    <tr key={item.id} className="relative border-t border-slate-200 hover:bg-slate-50">
                                        <td onClick={() => startEdit(idx, "title")} className="px-4 py-3 cursor-text max-w-[420px]">
                                            {!(editing && editingCell?.col === "title") ? (
                                                <div className="min-h-[48px] whitespace-pre-wrap">{item.title || <span className="text-slate-400">—</span>}</div>
                                            ) : (
                                                <textarea
                                                    ref={(el) => { inputRef.current = el; }}
                                                    value={item.title}
                                                    onChange={(e) => updateCell(idx, "title", e.target.value)}
                                                    onBlur={stopEdit}
                                                    onKeyDown={(e) => handleKeyDown(e)}
                                                    className="w-full h-28 p-2 resize-y outline-none border rounded"
                                                    placeholder="Введите наименование"
                                                />
                                            )}
                                        </td>

                                        {/* volume */}
                                        <td onClick={() => startEdit(idx, "volume")} className="px-4 py-3 cursor-text">
                                            {!(editing && editingCell?.col === "volume") ? (
                                                <div className="min-h-[36px]">{item.volume ?? <span className="text-slate-400">—</span>}</div>
                                            ) : (
                                                <input
                                                    ref={(el) => { inputRef.current = el; }}
                                                    type="number"
                                                    value={item.volume}
                                                    onChange={(e) => updateCell(idx, "volume", e.target.value)}
                                                    onBlur={stopEdit}
                                                    onKeyDown={(e) => handleKeyDown(e)}
                                                    className="w-full h-10 p-2 outline-none border rounded"
                                                />
                                            )}
                                        </td>

                                        <td onClick={() => startEdit(idx, "unitOfMeasurement")} className="px-4 py-3 cursor-text">
                                            {!(editing && editingCell?.col === "unitOfMeasurement") ? (
                                                <div className="min-h-[36px]">{item.unitOfMeasurement || <span className="text-slate-400">—</span>}</div>
                                            ) : (
                                                <input
                                                    ref={(el) => { inputRef.current = el; }}
                                                    type="text"
                                                    value={item.unitOfMeasurement}
                                                    onChange={(e) => updateCell(idx, "unitOfMeasurement", e.target.value)}
                                                    onBlur={stopEdit}
                                                    onKeyDown={(e) => handleKeyDown(e)}
                                                    className="w-full h-10 p-2 outline-none border rounded"
                                                />
                                            )}
                                        </td>

                                        {/* startDate */}
                                        <td onClick={() => startEdit(idx, "startDate")} className="px-4 py-3 cursor-text">
                                            {!(editing && editingCell?.col === "startDate") ? (
                                                <div className="min-h-[36px]">{item.startDate || <span className="text-slate-400">—</span>}</div>
                                            ) : (
                                                <input
                                                    ref={(el) => { inputRef.current = el; }}
                                                    type="text"
                                                    value={item.startDate}
                                                    onChange={(e) => updateCell(idx, "startDate", e.target.value)}
                                                    onBlur={stopEdit}
                                                    onKeyDown={(e) => handleKeyDown(e)}
                                                    placeholder="dd.mm.yyyy"
                                                    className="w-full h-10 p-2 outline-none border rounded"
                                                />
                                            )}
                                        </td>

                                        <td onClick={() => startEdit(idx, "endDate")} className="px-4 py-3 cursor-text">
                                            {!(editing && editingCell?.col === "endDate") ? (
                                                <div className="min-h-[36px]">{item.endDate || <span className="text-slate-400">—</span>}</div>
                                            ) : (
                                                <input
                                                    ref={(el) => { inputRef.current = el; }}
                                                    type="text"
                                                    value={item.endDate}
                                                    onChange={(e) => updateCell(idx, "endDate", e.target.value)}
                                                    onBlur={stopEdit}
                                                    onKeyDown={(e) => handleKeyDown(e)}
                                                    placeholder="dd.mm.yyyy"
                                                    className="w-full h-10 p-2 outline-none border rounded"
                                                />
                                            )}
                                        </td>

                                        <td className="px-4 py-3 text-center">
                                            <button onClick={() => deleteRow(idx)} className="inline-flex items-center justify-center h-9 px-3 rounded bg-white border hover:bg-red-50" title="Удалить строку">
                                                🗑
                                            </button>
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>

                {/* Кнопки */}
                <div className="w-full flex items-center justify-between gap-4">
                    <button className="bg-red-700 text-white px-6 py-2 rounded-lg" onClick={addJob}>Добавить строку</button>
                    <div className="flex gap-2">
                        <button className="bg-red-700 text-white px-6 py-2 rounded-lg" onClick={handleSave}>Сохранить</button>
                    </div>
                </div>
            </main>
        </div>
    );
}
