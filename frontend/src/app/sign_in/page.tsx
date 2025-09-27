'use client';

import * as Yup from "yup";
import {yupResolver} from "@hookform/resolvers/yup";
import {useState} from "react";
import {useForm} from "react-hook-form";
import {LoginFormData} from "@/models";
import {AuthUser} from "@/app/Api/Api";
import {useUserStore} from "@/storage/userstore";

const validationSchema = Yup.object().shape({
    email: Yup.string()
        .email('Некорректный формат электронной почты')
        .required('Электронная почта обязательна'),
    password: Yup.string()
        .min(4, 'Пароль должен содержать минимум 4 символа')
        .required('Пароль обязателен'),
});

export default function SignIn() {
    const [message, setMessage] = useState<string | null>(null);

    const {register, handleSubmit, formState: {errors}} = useForm({
        resolver: yupResolver(validationSchema)
    })
    const setUserData = useUserStore((state)=>state.setUserData);

    const onSubmit = async (data: LoginFormData) => {
        try {
            const {success, message, decoded} = await AuthUser(data.email, data.password);
            if (success && decoded) {
                setUserData({role:decoded.role, org:decoded.org, uuid:decoded.uuid})
                window.location.href = '/list_objects/';
            } else {
                setMessage(message || "Ошибка авторизации");
            }
        } catch (error) {
            setMessage(`${error}`);
        }
    };


    return (
        <div className="flex items-center justify-center min-h-screen bg-gray-300 px-2">
            <div className="bg-white rounded-md shadow-lg p-8 w-96">
                <h1 className="text-center text-lg font-medium mb-6">
                    Авторизация
                </h1>
                <form className="flex flex-col gap-8" onSubmit={handleSubmit(onSubmit)}>
                    <div className="flex flex-col gap-5">
                        <div>
                            <label className="block text-sm mb-1">Почта</label>
                            <input
                                {...register("email")}
                                type="text"
                                className="w-full border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                            {errors.email && <p className="text-red-600">{errors.email.message}</p>}
                        </div>
                        <div>
                            <label className="block text-sm mb-1">Пароль</label>
                            <input
                                {...register("password")}
                                type="password"
                                className="w-full border rounded-md p-2 text-sm focus:outline-none focus:ring-2 focus:ring-red-500"
                            />
                            {errors.password && <p className="text-red-600">{errors.password.message}</p>}
                        </div>
                    </div>
                    <button
                        type="submit"
                        className="w-full bg-red-700 hover:bg-red-800 text-white py-2 rounded-md"
                    >
                        Войти
                    </button>

                    {message && <p className="w-full text-center text-red-600 pt-2">{message}</p>}
                </form>

            </div>
        </div>
    );
}