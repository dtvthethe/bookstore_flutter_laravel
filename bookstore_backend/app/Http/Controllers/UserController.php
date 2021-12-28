<?php

namespace App\Http\Controllers;

use App\Http\Requests\User\LoginRequest;
use App\Http\Requests\User\RegisterRequest;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

/**
 * @OA\Info(title="My First API", version="0.1")
 */
class UserController extends Controller
{
    /**
     * Create Todo
     * @OA\Post (
     *     path="/api/todo/store",
     *     tags={"ToDo"},
     *     @OA\RequestBody(
     *         @OA\MediaType(
     *             mediaType="application/json",
     *             @OA\Schema(
     *                 @OA\Property(
     *                      type="object",
     *                      @OA\Property(
     *                          property="title",
     *                          type="string"
     *                      ),
     *                      @OA\Property(
     *                          property="content",
     *                          type="string"
     *                      )
     *                 ),
     *                 example={
     *                     "title":"example title",
     *                     "content":"example content"
     *                }
     *             )
     *         )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="success",
     *          @OA\JsonContent(
     *              @OA\Property(property="id", type="number", example=1),
     *              @OA\Property(property="title", type="string", example="title"),
     *              @OA\Property(property="content", type="string", example="content"),
     *              @OA\Property(property="updated_at", type="string", example="2021-12-11T09:25:53.000000Z"),
     *              @OA\Property(property="created_at", type="string", example="2021-12-11T09:25:53.000000Z"),
     *          )
     *      ),
     *      @OA\Response(
     *          response=400,
     *          description="invalid",
     *          @OA\JsonContent(
     *              @OA\Property(property="msg", type="string", example="fail"),
     *          )
     *      )
     * )
     */
    public function register(RegisterRequest $request)
    {
        $user = $request->validated();
        $user['password'] = Hash::make($user['password']);
        $user = User::create($user);

        return response()->json([
            'status' => 200,
            'data' => $user->toArray(),
            'messages' => 'Create successs.',
        ]);
    }

    public function login(LoginRequest $request)
    {
        $data = $request->validated();
        $credential = [
            'phone' => $data['phone'],
            'password' => $data['password'],
        ];

        if (!Auth::attempt($credential)) {
            return response()->json([
                'status' => 401,
                'data' => [],
                'messages' => 'Login fail.',
            ]);
        }

        $user = User::where('phone', $request['phone'])->firstOrFail();
        $token = $user->createToken($data['device_name'])->plainTextToken;

        return response()->json([
            'status' => 200,
            'data' => [
                'access_token' => $token,
                'token_type' => 'Bearer',
            ],
            'messages' => 'Create successs.',
        ]);
    }

    public function me(){
        return response()->json([
            'status' => 200,
            'data' => Auth::user()->toArray(),
            'messages' => 'Me.',
        ]);
    }

    public function logout() {
        Auth::user()->tokens()->delete();

        return response()->json([
            'status' => 200,
            'data' => [],
            'messages' => 'Logout success.',
        ]); 
    }
}
