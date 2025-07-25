import mongoose from 'mongoose';

const ReportSchema = new mongoose.Schema({
  clinicsName: String,
  childsName: String,
  age: Number,
  schoolId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'School'
  },
  optionalNotes: String,
  score: { 
    type: Number, 
    default: 0 
  },          
  manualScore: { 
    type: Number 
  }, 
  labeledBy: { 
    type: String 
  },          
  labeledAt: { 
    type: Date 
  },      
  flagforlabel: {
    type: Boolean,
    default: false,
  },
  labelling: String,
  imagePath: { type: String }, // Store relative file path, e.g., 'uploads/12345-image.jpg'
  houseAns: Object,
  personAns: Object,
  treeAns: Object,
  childId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Child',
    required: false, // Only set for parent/teacher reports
  },
  submittedBy: {
    role: { type: String, required: true },
    phone: { type: String, required: true },
  },
  submittedAt: {
    type: Date,
    default: Date.now,
  },
  clinicName: { type: String },
}, { timestamps: true });

export const Report = mongoose.model('Report', ReportSchema);