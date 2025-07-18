import mongoose from 'mongoose'; // 👈 Add this line

const UserSchema = new mongoose.Schema({
  name: { type: String, required: true },
  number: { type: String, required: true, unique: true },
  role: {
    type: String,
    enum: ['NGOAdmin', 'SchoolAdmin'],
    required: true,
  },
  assignedSchoolList: {
    type: [String],
    default: [],
    validate: {
      validator: function (arr) {
        return this.role === 'SchoolAdmin' ? arr.length <= 1 : true;
      },
      message: 'School Admin can only be assigned one school.'
    }
  }
}, { timestamps: true });

export const User = mongoose.model('User', UserSchema);