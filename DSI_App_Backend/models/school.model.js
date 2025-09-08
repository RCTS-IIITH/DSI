
 import mongoose from 'mongoose';

const SchoolSchema = new mongoose.Schema({
    schoolName: {
      type: String,
      required: true
    },
    address: {
      type: String,
      required: true
    },
    UDISE: {
      type: String,
      required: true,
      unique: true
    },
    contactNumber: {   // 👈 New Field
      type: Number,
      required: true 
    },
    teachers: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Teacher',
      default: []
    }],
    assignedProfessionals: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Professional',
      default: []
    }],
    assignedAdmins: [{
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    }]
  }, { timestamps: true });
  
  export const School = mongoose.model('School', SchoolSchema);