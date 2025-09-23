'use client';

export default function SignIn() {
    return (
        <div className="flex items-center justify-center min-h-screen bg-gray-300 px-2">
            <div className="bg-white rounded-md shadow-lg p-8 w-96">
                <h1 className="text-center text-lg font-medium mb-6">
                    Авторизация
                </h1>
                <form className="flex flex-col gap-8">
                    <div className="flex flex-col gap-5">
                        <div>
                            <label className="block text-sm mb-1">Почта</label>
                            <input
                                type="text"
                                className="w-full border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                        <div>
                            <label className="block text-sm mb-1">Пароль</label>
                            <input
                                type="password"
                                className="w-full border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                        </div>
                    </div>
                    <button
                        type="submit"
                        className="w-full bg-red-700 hover:bg-red-800 text-white py-2 rounded-md"
                    >
                        Войти
                    </button>
                </form>
            </div>
        </div>
    );
}