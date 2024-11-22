import cookieParser from "cookie-parser";
import dotenv from "dotenv";
dotenv.config({ path: '../.env' });
import express from "express";
import cors from 'cors';


const app = express();
app.use(express.urlencoded({ extended: true, limit: '1mb' }));
app.use(express.static('public'));
app.use(cookieParser())
app.use(cors({}))

// This method is a built-in middleware in
//  Express that parses incoming requests with JSON payloads.
app.use(express.json({ limit: '1mb' }));
try {
    console.log('Server started');
} catch (error) {
    app.on('error', (error) => {
        console.error(`Error: ${error.message}`);
    });
}

//routes 
import userRoutes from './routes/users.router.js';
import reportRoutes from './routes/reports.router.js';

app.use('/api/users', userRoutes);
app.use('/api/reports', reportRoutes);




// module.exports = app;
export default app;

