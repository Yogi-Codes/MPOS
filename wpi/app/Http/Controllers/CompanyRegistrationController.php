<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use App\Models\Model\Company;
use Brian2694\Toastr\Facades\Toastr;
use Illuminate\Contracts\Foundation\Application;
use Illuminate\Contracts\View\Factory;
use Illuminate\Contracts\View\View;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\DB;

class CompanyRegistrationController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return Application|Factory|View
     */
    public function index()
    {
        return view('registration');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param Request $request
     * @return RedirectResponse
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'first_name' => 'required',
            'last_name' => 'required',
            'sub_domain_prefix' => 'required|unique:companies',
            'email' => 'required|unique:admins',
            'phone' => 'unique:admins',
            'password' => 'required|same:confirm_password',
        ],[
            'sub_domain_prefix.unique'=>'Domain name has already been taken',
            'sub_domain_prefix.required'=>'Domain name is required',
        ]);

        DB::transaction(function () use ($request) {
            $company = new Company();
            $company->company_name = $request['company_name'];
            $company->sub_domain_prefix = $request['sub_domain_prefix'];
            $company->save();

            $admin = new Admin();
            $admin->f_name = $request['first_name'];
            $admin->l_name = $request['last_name'];
            $admin->email = $request['email'];
            $admin->phone = $request['phone_number'];
            $admin->company_id = $company['id'];
            $admin->password = bcrypt($request['password']);
            $admin->save();

            $company_id = $company['id'];
            DB::table('business_settings')->updateOrInsert(['key' => 'pagination_limit', 'company_id' => $company_id], [
                'value' => 25
            ]);
            DB::table('business_settings')->updateOrInsert(['key' => 'currency', 'company_id' => $company_id], [
                'value' => 'USD'
            ]);
            DB::table('business_settings')->updateOrInsert(['key' => 'stock_limit', 'company_id' => $company_id], [
                'value' => 25
            ]);
        });

        Toastr::success('Registration success, you can login now');
        return back();
    }
}
