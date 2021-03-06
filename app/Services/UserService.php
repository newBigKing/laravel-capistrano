<?php


namespace App\Services;


use App\Repositories\UserRepository;

class UserService
{
    /** @var UserRepository */
    protected $userRepository;

    public function __construct(UserRepository $userRepository)
    {
        $this->userRepository = $userRepository;
    }

    public function register()
    {
       return $this->userRepository->register();
    }
}