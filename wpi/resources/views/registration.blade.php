<!doctype html>
<html lang="en">
<head>
    <!-- Required meta tags -->
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="{{asset('public/assets/registration')}}/vendors/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="{{asset('public/assets/registration')}}/css/style.css" rel="stylesheet">
    <link href="{{asset('public/assets/registration')}}/css/responsive.css" rel="stylesheet">
    <link rel="stylesheet" href="{{asset('public/assets/admin')}}/css/toastr.css">
    <title>6amtech.com</title>
</head>

<body>
<div class="body_wrapper frm-vh-md-100">
    <div class="header_top d-flex align-items-center justify-content-between">
        <a href="index.html" class="logo"><img src="{{asset('public/assets/registration')}}/img/logo.png" alt=""></a>
        <p class="form_footer_text text-right">Already have an account? <a href="{{route('admin.auth.login')}}">Sign in
            </a>
        </p>
    </div>
    <div class="formify_body formify_signup_fullwidth parallax-effect d-flex">
        <div class="formify_left_fullwidth frm-vh-md-100"
             data-bg-img="{{asset('public/assets/registration')}}/img/background-bg-left.jpg">
        </div>
        <div class="formify_right_fullwidth d-flex align-items-center justify-content-center">
            <div class="parallax_img">
                <div class="p_img one">
                    <img class="layer layer2" data-depth="0.5"
                         src="{{asset('public/assets/registration')}}/img/parallax-img/polygon1.png" alt="">
                </div>
                <div class="p_img two"><img class="layer layer2" data-depth="0.4"
                                            src="{{asset('public/assets/registration')}}/img/parallax-img/polygon2.png"
                                            alt=""></div>
                <div class="p_img three"><img class="layer layer2" data-depth="0.5"
                                              src="{{asset('public/assets/registration')}}/img/parallax-img/polygon3.png"
                                              alt=""></div>
                <div class="p_img four"><img class="layer layer2" data-depth="0.5"
                                             src="{{asset('public/assets/registration')}}/img/parallax-img/polygon4.png"
                                             alt=""></div>
                <div class="p_img five"><img class="layer layer2" data-depth="0.5"
                                             src="{{asset('public/assets/registration')}}/img/parallax-img/polygon5.png"
                                             alt=""></div>
                <div class="p_img six"><img class="layer layer2" data-depth="0.5"
                                            src="{{asset('public/assets/registration')}}/img/parallax-img/polygon6.png"
                                            alt=""></div>
            </div>
            <div class="formify_content_body">
                <h2 class="form_title">Company Registration</h2>
                <form action="{{route('company.store')}}" class="signup_form signup_form_style_two" method="POST">
                    @csrf
                    <div class="form-group">
                        <input value="{{old('company_name')}}" placeholder="Company Name" class="form-control"
                               type="text" id="company_name" name="company_name" aria-required="true" required>
                    </div>

                    <div class="form-group input-group">
                        <input value="{{old('sub_domain_prefix')}}" type="text" class="form-control"
                               placeholder="Domain Prefix" id="sub_domain_prefix" name="sub_domain_prefix"
                               aria-required="true" required>
                        <div class="input-group-append">
                            <span class="input-group-text" id="basic-addon2">.codemond.com</span>
                        </div>
                    </div>

                    <div class="form-group">
                        <input value="{{old('first_name')}}" class="form-control" type="text" id="first_name"
                               name="first_name" placeholder="First name" required=""
                               aria-required="true">
                    </div>

                    <div class="form-group">
                        <input value="{{old('last_name')}}" class="form-control" type="text" id="last_name"
                               name="last_name" placeholder="Last name" required=""
                               aria-required="true">
                    </div>

                    <div class="form-group">
                        <input value="{{old('email')}}" class="form-control" type="text" id="email" name="email"
                               placeholder="Email address" required=""
                               aria-required="true">
                    </div>
                    <div class="form-group">
                        <input value="{{old('phone')}}" class="form-control" type="text" id="phone_number" name="phone"
                               placeholder="Phone Number ( Optional )" required=""
                               aria-required="true">
                    </div>
                    <div class="form-group">
                        <input type="password" placeholder="Password" class="form-control" name="password" id="inputPassword" required="">
                    </div>
                    <div class="form-group">
                        <input type="password" placeholder="Confirm Password" class="form-control" name="confirm_password" id="inputPassword"
                               required="">
                    </div>
                    <div class="form-group">
                        <button type="submit" class="btn thm_btn thm_btn_green">Sign Up</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Optional JavaScript; choose one of the two! -->
<script src="{{asset('public/assets/registration')}}/js/jquery-3.4.1.min.js"></script>
<!-- Option 1: Bootstrap Bundle with Popper -->
<script src="{{asset('public/assets/registration')}}/vendors/bootstrap/js/popper.min.js"></script>
<script src="{{asset('public/assets/registration')}}/vendors/bootstrap/js/bootstrap.min.js"></script>
<script src="{{asset('public/assets/registration')}}/js/parallax.js"></script>
<script src="{{asset('public/assets/registration')}}/js/jquery.parallax-scroll.js"></script>
<script src="{{asset('public/assets/registration')}}/js/main.js"></script>
<script src="{{asset('public/assets/admin')}}/js/toastr.js"></script>

{!! Toastr::message() !!}

@if ($errors->any())
    <script>
        @foreach($errors->all() as $error)
        toastr.error('{{$error}}', Error, {
            CloseButton: true,
            ProgressBar: true
        });
        @endforeach
    </script>
@endif

</body>
</html>
