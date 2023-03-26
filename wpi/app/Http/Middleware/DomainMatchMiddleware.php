<?php

namespace App\Http\Middleware;

use App\CPU\Helpers;
use App\Models\Model\Company;
use Closure;
use Illuminate\Http\Request;

class DomainMatchMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param \Illuminate\Http\Request $request
     * @param \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $subdomains = Helpers::sub_domain();
        if (count($subdomains) > 0) {
            $match_domain = auth('admin')->user()->company->sub_domain_prefix;
            if ($match_domain == $subdomains[0]) {
                return $next($request);
            }
        }
        return redirect()->to('/');
    }
}
