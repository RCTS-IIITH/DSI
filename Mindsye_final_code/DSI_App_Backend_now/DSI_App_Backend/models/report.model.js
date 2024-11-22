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



const ReportSchema = new mongoose.Schema({
    clinicsName: {
        type: String,
        required: true
    },
    childsName: {
        type: String,
        required: true
    },
    age: {
        type: String,
        required : true
    },
    optionalNotes: {
        type: String,
        required: false
    },
    flagforlabel: {
        type: String,
        required: true
    },
    labelling: {
        type: String,
        required: false
    },
    imageurl: {
        type: String,
        required: true
    },
    houseAns: {
        type: Object,
        required: true,
        properties: {
            WhoLivesHere: { type: String, required: true },
            ArethereHappy: { type: String, required: true },
            DoPeopleVisitHere: { type: String, required: true },
            Whatelsepeoplewant: { type: String, required: true }
        }
    },
    personAns: {
        type: Object,
        required: true,
        properties: {
            Whoisthisperson: { type: String, required: true },
            Howoldarethey: { type: String, required: true },
            Whatsthierfavthing: { type: String, required: true },
            Whattheydontlike: { type: String, required: true }
        }
    },
    treeAns:{
        type: Object,
        required: true,
        properties: {
            Whatkindoftree: { type: String, required: true },
            howoldisit: { type: String, required: true },
            whatseasonisit: { type: String, required: true },
            anyonetriedtocut: { type: String, required: true},
            whatelsegrows: { type: String, required: true},
            whowaters: { type: String, required: true},
            doesitgetenoughsunshine: { type: String, required: true}
        }           
    },
    score: {
        type: String,
        required: false
    },
    analysis: {
        type: String,
        required: false
    },
}, { timestamps: true });

// export const Teacher = mongoose.model('Teacher', TeacherSchema);
// export const Professional = mongoose.model('Professional', ProfessionalSchema);
export const Report = mongoose.model('Report', ReportSchema);