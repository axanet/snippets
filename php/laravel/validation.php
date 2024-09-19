<?php

$request->validate([
    'name' => 'required|string|max:255',
    'email' => 'required|email|unique:users,email',
    'password' => 'required|string|min:8|confirmed',
    'age' => 'nullable|integer|min:18',
    'link' => 'required|active_url', // 'url' validates, that the input is a url, 'active_url' also verifies that the link is active
    'avatar' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
]);
