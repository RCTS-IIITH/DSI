// Copyright 2024 Umang Patel
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     https://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import mongoose from 'mongoose';

const ChildSchema = new mongoose.Schema({
    name : {
        type: String,
        required: true
    },
    rollNumber : {
        type: String,
        required: false
    },
    schoolID : {
        type: String,
        required: false
    },
    parentName: {
        type: String,
        required: false
    },
    parentPhoneNumber: {
        type: Number,
        required: false
    },
    class : {
        type: Number,
        required: false
    },
    age : {
        type: Number,
        required: true 
    },

}, { timestamps: true });

export const Child = mongoose.model('Child', ChildSchema);