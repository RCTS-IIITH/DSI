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
  imageurl: String,
  houseAns: Object,
  personAns: Object,
  treeAns: Object,
  submittedBy: {
    role: { type: String, required: true },
    phone: { type: String, required: true },
  },
  submittedAt: {
    type: Date,
    default: Date.now,
  },
}, { timestamps: true });

export const Report = mongoose.model('Report', ReportSchema);