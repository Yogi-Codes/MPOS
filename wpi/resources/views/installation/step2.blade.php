@extends('layouts.blank')
@section('content')
    <div class="container">
        <div class="row pt-5">
            <div class="col-md-12">
                @if(session()->has('error'))
                    <div class="alert alert-danger" role="alert">
                        {{session('error')}}
                    </div>
                @endif
                <div class="mar-ver pad-btm text-center d-none">
                    <h1 class="h3">Purchase Code</h1>
                    <p>Provide your codecanyon purchase code.<br>
                    </p>
                </div>
                <div class="text-muted font-13">
                    <form method="POST" action="{{ route('purchase.code',['token'=>bcrypt('step_3')]) }}">
                        @csrf
                        <div class="form-group d-none">
                            <label for="purchase_code">Codecanyon Username</label>
                            <input type="text" value="licensed"
                                   class="form-control" id="username"
                                   name="username" placeholder="Enter random value" required>
                        </div>

                        <div class="form-group d-none">
                            <label for="purchase_code">Purchase Code</label>
                            <input type="text"
                                   value="licensed"
                                   class="form-control" id="purchase_key"
                                   name="purchase_key" placeholder="Enter random value" required>
                        </div>
                        <div class="text-center">
                            <button type="submit" class="btn btn-info">Proceed to install</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
@endsection
