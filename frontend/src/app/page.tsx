"use client";

import {Header} from "@/app/components/header";
import Link from "next/link";
import styles from "@/app/styles/variables.module.css";

export default function AboutPage() {
    return (
        <div className="min-h-screen flex flex-col bg-[#D0D0D0]">
            <Header/>
            <main className="flex-1 w-full max-w-6xl mx-auto bg-white mt-10 px-6 sm:px-8 py-8 sm:py-12">
                <div className="mb-8">
                    <h1 className="text-2xl sm:text-3xl font-semibold text-gray-900 mb-4">
                        О нас
                    </h1>
                    <p className="text-base text-gray-700 leading-relaxed mb-4">
                        Мы создаём современные цифровые решения для строительной отрасли, где особенно важны
                        прозрачность, точность и оперативность. Наше приложение помогает объединить участников
                        проекта в едином рабочем пространстве и сделать все процессы управляемыми: от первых
                        планов до итоговой сдачи объекта.
                    </p>
                    <p className="text-base text-gray-700 leading-relaxed">
                        Наша миссия — упростить взаимодействие между всеми сторонами, сократить издержки и повысить
                        качество строительства. Мы уверены, что цифровизация позволяет по-новому взглянуть на привычные
                        процессы и открывает возможности для более эффективного сотрудничества.
                    </p>
                </div>

                <div className="mb-8">
                    <h2 className="text-xl font-semibold text-gray-900 mb-3">Ключевые роли в системе</h2>
                    <p className="text-base text-gray-700 leading-relaxed mb-6">
                        Для удобства и чёткой организации работы мы предусмотрели три типа пользователей.
                        Каждая роль отражает реальные задачи участников строительного процесса и помогает
                        сделать их взаимодействие максимально эффективным.
                    </p>

                    <div className="grid gap-6 sm:grid-cols-3">
                        <div className="border rounded-lg shadow-sm p-5 bg-gray-50 hover:shadow-md transition">
                            <h3 className="text-lg font-semibold text-red-700 mb-2">Заказчик</h3>
                            <p className="text-sm text-gray-700 leading-relaxed">
                                Получает полный контроль над проектом: видит сроки, прогресс выполнения,
                                фото- и текстовые отчёты, а также может оперативно принимать управленческие решения.
                            </p>
                        </div>

                        <div className="border rounded-lg shadow-sm p-5 bg-gray-50 hover:shadow-md transition">
                            <h3 className="text-lg font-semibold text-red-700 mb-2">Инспектор</h3>
                            <p className="text-sm text-gray-700 leading-relaxed">
                                Контролирует качество и соблюдение стандартов. Все замечания и проверки фиксируются
                                в системе, что снижает риски и упрощает процесс взаимодействия с другими участниками.
                            </p>
                        </div>

                        <div className="border rounded-lg shadow-sm p-5 bg-gray-50 hover:shadow-md transition">
                            <h3 className="text-lg font-semibold text-red-700 mb-2">Подрядчик</h3>
                            <p className="text-sm text-gray-700 leading-relaxed">
                                Управляет задачами своей команды, отмечает выполненные этапы и поддерживает
                                постоянную связь с заказчиком и инспектором, ускоряя согласования и улучшая результат.
                            </p>
                        </div>
                    </div>
                </div>

                <div className="mt-12 border rounded-lg shadow-md p-6 bg-gray-50 text-center">
                    <h2 className="text-lg font-semibold text-gray-900 mb-3">
                        Готовы начать работу?
                    </h2>
                    <p className="text-base text-gray-700 mb-6">
                        Для начала перейдите в список объектов, чтобы выбрать или создать проект.
                    </p>
                    <Link
                        href="/list_objects/"
                        className={`${styles.mainButton}`}
                    >
                        Перейти в список объектов
                    </Link>
                </div>
            </main>
        </div>
    );
}
