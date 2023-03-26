<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Redirect;
use Illuminate\Support\Facades\Session;

class LanguageController extends Controller
{
    public function switchLang(Request $request, $local)
    {
        if (array_key_exists($local, config('languages.languages'))) {
            App::setLocale($local);
            Session::put('local', $local);
        }
        return Redirect::back();
    }
}
?>