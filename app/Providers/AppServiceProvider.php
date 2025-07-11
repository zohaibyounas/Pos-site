<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
public function register(): void
{
    if ($this->app->environment() !== 'production' && class_exists(\Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class)) {
        $this->app->register(\Barryvdh\LaravelIdeHelper\IdeHelperServiceProvider::class);
    }
}



    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
