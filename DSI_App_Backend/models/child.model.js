
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
    schoolID: {
        type: mongoose.Schema.Types.ObjectId, // 👈 Now it's an ObjectId reference
        ref: 'School',                         // 👈 Reference to School model
        required: false
      },
    organizationId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Organization',
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