"use client";

import { Header } from "@/app/components/header";
import { useState, useRef } from "react";
import { useRouter } from "next/navigation";
import styles from "@/app/styles/variables.module.css";
import { setForeman, projectCommit, uploadProjectFiles } from "@/app/Api/Api";

export default function ActivationPage() {
    const [selectedFiles, setSelectedFiles] = useState<File[]>([]);
    const [message, setMessage] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement | null>(null);
    const router = useRouter();

    const [form, setForm] = useState({
        lastName: "",
        firstName: "",
        middleName: "",
    });

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files.length > 0) {
            setSelectedFiles(Array.from(e.target.files));
        } else {
            setSelectedFiles([]);
        }
    };

    const handleSubmit = async () => {
        setMessage(null);
        setLoading(true);

        const projectUuid = localStorage.getItem("projectUuid");
        if (!projectUuid) {
            setMessage("Нет projectUuid в localStorage");
            setLoading(false);
            return;
        }

        // 1 запрос - setForeman
        const foremanRes = await setForeman(
            projectUuid,
            form.firstName,
            form.lastName,
            form.middleName
        );
        if (!foremanRes.success) {
            setMessage(foremanRes.message);
            setLoading(false);
            return;
        }

        // 2 запрос - projectCommit
        const commitRes = await projectCommit(projectUuid);
        if (!commitRes.success) {
            setMessage(commitRes.message);
            setLoading(false);
            return;
        }

        // 3 запрос - uploadProjectFiles
        if (selectedFiles.length > 0) {
            const { uploaded, errors } = await uploadProjectFiles(projectUuid, selectedFiles);
            if (errors.length > 0) {
                setMessage(`Ошибки при загрузке файлов: ${errors.join(", ")}`);
                setLoading(false);
                return;
            }
            console.log("Файлы успешно загружены:", uploaded);
        }

        setLoading(false);
        router.push("/list_objects/");
    };

    return (
        <div className="relative flex justify-center bg-[#D0D0D0] min-h-screen">
            <Header />
            <main className="w-full max-w-[1000px] bg-white mt-[50px] rounded-lg shadow-md px-8 py-10">
                <h1 className="text-xl font-semibold mb-8">Активация объекта</h1>

                <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
                    <div className="grid grid-cols-[150px_1fr] gap-4 items-center">
                        <label className="text-gray-700">Фамилия</label>
                        <input
                            type="text"
                            value={form.lastName}
                            onChange={(e) => setForm({ ...form, lastName: e.target.value })}
                            className="border border-gray-300 rounded px-3 py-2 w-full"
                        />
                    </div>

                    <div className="grid grid-cols-[150px_1fr] gap-4 items-center">
                        <label className="text-gray-700">Имя</label>
                        <input
                            type="text"
                            value={form.firstName}
                            onChange={(e) => setForm({ ...form, firstName: e.target.value })}
                            className="border border-gray-300 rounded px-3 py-2 w-full"
                        />
                    </div>

                    <div className="grid grid-cols-[150px_1fr] gap-4 items-center">
                        <label className="text-gray-700">Отчество</label>
                        <input
                            type="text"
                            value={form.middleName}
                            onChange={(e) => setForm({ ...form, middleName: e.target.value })}
                            className="border border-gray-300 rounded px-3 py-2 w-full"
                        />
                    </div>

                    {/* Кнопки на одном уровне */}
                    <div className="flex justify-between items-center mt-8">
                        <div className="flex items-center gap-4">
                            <button
                                type="button"
                                onClick={() => fileInputRef.current?.click()}
                                className={`${styles.mainButton}`}
                            >
                                Прикрепить файл
                            </button>
                            <input
                                ref={fileInputRef}
                                type="file"
                                multiple
                                accept=".pdf,.jpg,.jpeg,.png,.gif,.doc,.docx"
                                className="hidden"
                                onChange={handleFileChange}
                            />
                            <span className="text-sm text-gray-600">
                {selectedFiles.length > 0
                    ? `Выбрано файлов: ${selectedFiles.length}`
                    : "Файлы не выбраны"}
              </span>
                        </div>

                        <button
                            type="button"
                            disabled={loading}
                            onClick={handleSubmit}
                            className={`${styles.mainButton}`}
                        >
                            {loading ? "Отправка..." : "Отправить на активацию"}
                        </button>
                    </div>

                    {/* Список выбранных файлов */}
                    {selectedFiles.length > 0 && (
                        <ul className="mt-4 list-disc list-inside text-sm text-gray-700">
                            {selectedFiles.map((file, idx) => (
                                <li key={idx}>{file.name}</li>
                            ))}
                        </ul>
                    )}

                    {/* Сообщения об ошибках */}
                    {message && (
                        <p className="w-full text-center text-red-600 pt-2">{message}</p>
                    )}
                </form>
            </main>
        </div>
    );
}
