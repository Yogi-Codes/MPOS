<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Validation Language Lines
    |--------------------------------------------------------------------------
    |
    | The following language lines contain the default error messages used by
    | the validator class. Some of these rules have multiple versions such
    | as the size rules. Feel free to tweak each of these messages here.
    |
    */

    'accepted' => 'ต้องยอมรับ :attribute',
    'accepted_if' => 'ต้องยอมรับ :attribute เมื่อ :other เป็น :value',
    'active_url' => ':attribute ไม่ใช่ URL ที่ถูกต้อง',
    'after' => ':attribute ต้องเป็นวันที่หลังจาก :date',
    'after_or_equal' => ':attribute ต้องเป็นวันที่หลังหรือเท่ากับ :date',
    'alpha' => ':attribute ต้องมีเฉพาะตัวอักษร',
    'alpha_dash' => ':attribute ต้องมีเฉพาะตัวอักษร ตัวเลข ขีดล่าง และขีดกลาง',
    'alpha_num' => ':attribute ต้องมีเฉพาะตัวอักษรและตัวเลข',
    'array' => ':attribute ต้องเป็นอาร์เรย์',
    'before' => ':attribute ต้องเป็นวันที่ก่อน :date',
    'before_or_equal' => ':attribute ต้องเป็นวันที่ก่อนหรือเท่ากับ :date',
    'between' => [
        'numeric' => ':attribute ต้องอยู่ระหว่าง :min และ :max',
        'file' => ':attribute ต้องมีขนาดระหว่าง :min และ :max กิโลไบต์',
        'string' => ':attribute ต้องมีความยาวระหว่าง :min และ :max ตัวอักษร',
        'array' => ':attribute ต้องมีจำนวนรายการอยู่ระหว่าง :min และ :max รายการ',
    ],

    'boolean' => 'ฟิลด์ :attribute ต้องเป็นจริงหรือเท็จ',
    'confirmed' => 'การยืนยัน :attribute ไม่ตรงกัน',
    'current_password' => 'รหัสผ่านไม่ถูกต้อง',
    'date' => ':attribute ไม่ใช่วันที่ที่ถูกต้อง',
    'date_equals' => ':attribute ต้องเป็นวันที่เท่ากับ :date',
    'date_format' => ':attribute ไม่ตรงกับรูปแบบ :format',
    'different' => ':attribute และ :other ต้องไม่เหมือนกัน',
    'digits' => ':attribute ต้องเป็นตัวเลข :digits หลัก',
    'digits_between' => ':attribute ต้องเป็นตัวเลขระหว่าง :min ถึง :max หลัก',
    'dimensions' => ':attribute มีขนาดรูปภาพที่ไม่ถูกต้อง',
    'distinct' => 'ฟิลด์ :attribute มีค่าที่ซ้ำกัน',
    'email' => ':attribute ต้องเป็นที่อยู่อีเมลที่ถูกต้อง',
    'ends_with' => ':attribute ต้องลงท้ายด้วยค่าใดค่าหนึ่งใน :values',
    'exists' => ':attribute ที่เลือกไม่ถูกต้อง',
    'file' => ':attribute ต้องเป็นไฟล์',
    'filled' => 'ฟิลด์ :attribute ต้องมีค่า',
    'gt' => [
    'numeric' => ':attribute ต้องมากกว่า :value',
    'file' => ':attribute ต้องมีขนาดมากกว่า :value กิโลไบต์',
    'string' => ':attribute ต้องมีความยาวมากกว่า :value ตัวอักษร',
    'array' => ':attribute ต้องมีมากกว่า :value รายการ',
    ],
    'gte' => [
        'numeric' => ':attribute ต้องมีค่ามากกว่าหรือเท่ากับ :value',
        'file' => ':attribute ต้องมีขนาด :value กิโลไบต์หรือมากกว่า',
        'string' => ':attribute ต้องมีอักขระ :value หรือมากกว่า',
        'array' => ':attribute ต้องมีอย่างน้อย :value รายการ',
        ],
        'image' => ':attribute ต้องเป็นรูปภาพ',
        'in' => ':attribute ที่เลือกไม่ถูกต้อง',
        'in_array' => 'ฟิลด์ :attribute ไม่มีอยู่ใน :other',
        'integer' => ':attribute ต้องเป็นจำนวนเต็ม',
        'ip' => ':attribute ต้องเป็นที่อยู่ IP ที่ถูกต้อง',
        'ipv4' => ':attribute ต้องเป็นที่อยู่ IPv4 ที่ถูกต้อง',
        'ipv6' => ':attribute ต้องเป็นที่อยู่ IPv6 ที่ถูกต้อง',
        'json' => ':attribute ต้องเป็นสตริง JSON ที่ถูกต้อง',
        'lt' => [
        'numeric' => ':attribute ต้องมีค่าน้อยกว่า :value',
        'file' => ':attribute ต้องมีขนาดน้อยกว่า :value กิโลไบต์',
        'string' => ':attribute ต้องมีอักขระน้อยกว่า :value',
        'array' => ':attribute ต้องมีรายการน้อยกว่า :value',
        ],
        'lte' => [
        'numeric' => ':attribute ต้องมีค่าน้อยกว่าหรือเท่ากับ :value',
        'file' => ':attribute ต้องมีขนาดน้อยกว่าหรือเท่ากับ :value กิโลไบต์',
        'string' => ':attribute ต้องมีอักขระน้อยกว่าหรือเท่ากับ :value',
        'array' => ':attribute ต้องมีรายการไม่เกิน :value',
        ],
        'max' => [
        'numeric' => ':attribute ต้องมีค่าไม่เกิน :max',
        'file' => ':attribute ต้องมีขนาดไม่เกิน :max กิโลไบต์',
        'string' => ':attribute ต้องมีอักขระไม่เกิน :max',
        'array' => ':attribute ต้องมีรายการไม่เกิน :max',
        ],
        'mimes' => 'ฟิลด์ :attribute ต้องเป็นไฟล์ประเภท :values',
        'mimetypes' => 'ฟิลด์ :attribute ต้องเป็นไฟล์ประเภท :values',
        'min' => [
        'numeric' => 'ฟิลด์ :attribute ต้องมีค่าอย่างน้อย :min',
        'file' => 'ฟิลด์ :attribute ต้องมีขนาดอย่างน้อย :min กิโลไบต์',
        'string' => 'ฟิลด์ :attribute ต้องมีจำนวนอักขระอย่างน้อย :min ตัว',
        'array' => 'ฟิลด์ :attribute ต้องมีองค์ประกอบอย่างน้อย :min รายการ',
        ],
        'multiple_of' => 'ฟิลด์ :attribute ต้องเป็นตัวเลขที่เป็นเลขคู่ของ :value',
        'not_in' => 'ฟิลด์ :attribute ที่เลือกไม่ถูกต้อง',
        'not_regex' => 'รูปแบบของฟิลด์ :attribute ไม่ถูกต้อง',
        'numeric' => 'ฟิลด์ :attribute ต้องเป็นตัวเลข',
        'password' => 'รหัสผ่านไม่ถูกต้อง',
        'present' => 'ฟิลด์ :attribute จำเป็นต้องมีอยู่',
        'regex' => 'รูปแบบของฟิลด์ :attribute ไม่ถูกต้อง',
        'required' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูล',
        'required_if' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูลเมื่อ :other เป็น :value',
        'required_unless' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูลเว้นแต่ :other อยู่ใน :values',
        'required_with' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูลเมื่อ :values มีอยู่',
        'required_with_all' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูลเมื่อ :values มีอยู่ทั้งหมด',
        'required_without' => 'ฟิลด์ :attribute จำเป็นต้องกรอกข้อมูลเมื่อ :values ไม่มีอยู่',
        'required_without_all' => 'ต้องระบุ :attribute เมื่อไม่มี :values ใดๆ ปรากฏอยู่',
        'prohibited' => ':attribute ไม่ได้รับอนุญาต',
        'prohibited_if' => ':attribute ไม่ได้รับอนุญาตเมื่อ :other เป็น :value',
        'prohibited_unless' => ':attribute ไม่ได้รับอนุญาตเว้นแต่ :other มีอยู่ใน :values',
        'prohibits' => ':attribute ไม่อนุญาตให้ :other ปรากฏอยู่',
        'same' => ':attribute และ :other ต้องตรงกัน',
        'size' => [
        'numeric' => ':attribute ต้องมีขนาด :size',
        'file' => ':attribute ต้องมีขนาด :size กิโลไบต์',
        'string' => ':attribute ต้องมี :size ตัวอักษร',
        'array' => ':attribute ต้องมีสมาชิก :size ตัว',
        ],
        'starts_with' => ':attribute ต้องขึ้นต้นด้วยหนึ่งในค่าต่อไปนี้: :values',
        'string' => ':attribute ต้องเป็นตัวอักษร',
        'timezone' => ':attribute ต้องเป็นโซนเวลาที่ถูกต้อง',
        'unique' => ':attribute ถูกใช้งานแล้ว',
        'uploaded' => ':attribute ไม่สามารถอัปโหลดได้',
        'url' => ':attribute ต้องเป็น URL ที่ถูกต้อง',
        'uuid' => ':attribute ต้องเป็น UUID ที่ถูกต้อง',

    /*
    |--------------------------------------------------------------------------
    | Custom Validation Language Lines
    |--------------------------------------------------------------------------
    |
    | Here you may specify custom validation messages for attributes using the
    | convention "attribute.rule" to name the lines. This makes it quick to
    | specify a specific custom language line for a given attribute rule.
    |
    */

    'custom' => [
        'attribute-name' => [
            'rule-name' => 'custom-message',
        ],
    ],

    /*
    |--------------------------------------------------------------------------
    | Custom Validation Attributes
    |--------------------------------------------------------------------------
    |
    | The following language lines are used to swap our attribute placeholder
    | with something more reader friendly such as "E-Mail Address" instead
    | of "email". This simply helps us make our message more expressive.
    |
    */

    'attributes' => [],

];
