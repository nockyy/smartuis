require('dotenv').config(); // Carga las variables de entorno desde .env
const express = require('express');
const { MongoClient, ObjectId } = require('mongodb'); // Importa MongoClient y ObjectId
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;
const mongoUri = process.env.MONGO_URI;

if (!mongoUri) {
    console.error("Error: MONGO_URI no está definida en el archivo .env");
    process.exit(1); // Sale de la aplicación si no hay URI
}

// Middleware
app.use(cors()); // Permite peticiones desde tu app Flutter
app.use(express.json()); // Permite que el servidor entienda JSON en el cuerpo de las peticiones

let db; // Variable para almacenar la conexión a la base de datos

// Conectar a MongoDB
async function connectToMongo() {
    try {
        const client = new MongoClient(mongoUri);
        await client.connect();
        db = client.db('SMART-UIS_bd'); // Asigna la base de datos a la variable global 'db'
        console.log("Conectado a MongoDB con éxito desde el backend!");
    } catch (error) {
        console.error("Error al conectar a MongoDB desde el backend:", error);
        // Si la conexión falla al inicio, puedes optar por salir de la app
        // o intentar reconectar. Para este ejemplo, solo logueamos el error.
    }
}

// *** RUTAS (ENDPOINTS) DE LA API ***

// Ruta de prueba
app.get('/', (req, res) => {
    res.send('API de Smart UIS Comedores funcionando!');
});

// 1. Registro de Usuario
app.post('/register', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const { email, password, nombre, apellido, codigoEstudiantil, services } = req.body;

    if (!email || !password || !nombre || !apellido || !codigoEstudiantil || !services) {
        return res.status(400).json({ message: "Todos los campos son requeridos." });
    }

    try {
        const usersCollection = db.collection('users');
        const existingUser = await usersCollection.findOne({ email });
        if (existingUser) {
            return res.status(409).json({ message: "El email ya está registrado." });
        }

        const newUser = {
            email,
            password, // En producción: HASH la contraseña aquí (ej. con bcrypt)
            nombre,
            apellido,
            codigoEstudiantil,
            services,
            streakCount: 0,
            points: 0,
            // Agrega un campo 'createdAt' si quieres timestamp de creación
        };
        const result = await usersCollection.insertOne(newUser);
        res.status(201).json({ message: "Usuario registrado con éxito!", userId: result.insertedId });
    } catch (error) {
        console.error("Error en el registro:", error);
        res.status(500).json({ message: "Error interno del servidor al registrar usuario." });
    }
});

// 2. Inicio de Sesión de Usuario
app.post('/login', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ message: "Email y contraseña son requeridos." });
    }

    try {
        const usersCollection = db.collection('users');
        // En producción: Compara la contraseña HASHED
        const user = await usersCollection.findOne({ email, password });
        if (user) {
            // Elimina la contraseña del objeto antes de enviarla al cliente
            const { password, ...userWithoutPassword } = user;
            // Envía el _id del usuario como string para que Flutter pueda usarlo fácilmente
            userWithoutPassword.id = userWithoutPassword._id.toString();
            res.status(200).json({ message: "Inicio de sesión exitoso!", user: userWithoutPassword });
        } else {
            res.status(401).json({ message: "Credenciales incorrectas." });
        }
    } catch (error) {
        console.error("Error en el login:", error);
        res.status(500).json({ message: "Error interno del servidor al iniciar sesión." });
    }
});

// 3. Obtener Reserva Activa del Usuario
app.get('/reservations/:userId', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const userId = req.params.userId;

    try {
        // Usa ObjectId para buscar por _id si el userId es el _id de MongoDB
        const reservation = await db.collection('reservas').findOne({ userId });
        if (reservation) {
            res.status(200).json(reservation);
        } else {
            res.status(404).json({ message: "No se encontró reserva activa para este usuario." });
        }
    } catch (error) {
        console.error("Error al obtener reserva:", error);
        res.status(500).json({ message: "Error interno del servidor al obtener reserva." });
    }
});

// 4. Actualizar/Crear Reserva
app.post('/reservations', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const { userId, tipo, fecha, hora } = req.body; // Asegúrate de que fecha y hora se envíen como strings

    if (!userId || !tipo || !fecha || !hora) {
        return res.status(400).json({ message: "Todos los campos de la reserva son requeridos." });
    }

    try {
        const reservasCollection = db.collection('reservas');
        const result = await reservasCollection.replaceOne(
            { userId, tipo }, // Buscar por userId y tipo para una única reserva activa por tipo
            { userId, tipo, fecha, hora },
            { upsert: true } // Si no existe, la inserta
        );
        res.status(200).json({ message: "Reserva actualizada/creada con éxito!", result });
    } catch (error) {
        console.error("Error al guardar reserva:", error);
        res.status(500).json({ message: "Error interno del servidor al guardar reserva." });
    }
});

// 5. Eliminar Reserva
app.delete('/reservations/:userId/:tipoReserva', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const userId = req.params.userId;
    const tipoReserva = req.params.tipoReserva;

    try {
        const result = await db.collection('reservas').deleteOne({ userId, tipo: tipoReserva });
        if (result.deletedCount === 0) {
            return res.status(404).json({ message: "Reserva no encontrada." });
        }
        res.status(200).json({ message: "Reserva eliminada con éxito!" });
    } catch (error) {
        console.error("Error al eliminar reserva:", error);
        res.status(500).json({ message: "Error interno del servidor al eliminar reserva." });
    }
});

// 6. Actualizar Datos de Usuario
app.put('/users/:userId', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const userId = req.params.userId;
    const updates = req.body; // Los campos a actualizar (nombre, apellido, email)

    try {
        const usersCollection = db.collection('users');
        const result = await usersCollection.updateOne(
            { _id: new ObjectId(userId) }, // Busca por ObjectId
            { $set: updates } // Aplica las actualizaciones
        );

        if (result.matchedCount === 0) {
            return res.status(404).json({ message: "Usuario no encontrado." });
        }
        res.status(200).json({ message: "Datos de usuario actualizados con éxito!", result });
    } catch (error) {
        console.error("Error al actualizar datos de usuario:", error);
        res.status(500).json({ message: "Error interno del servidor al actualizar datos de usuario." });
    }
});

// 7. Actualizar Contraseña (NO SEGURO EN PRODUCCIÓN SIN HASHING)
app.put('/users/:userId/password', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const userId = req.params.userId;
    const { newPassword } = req.body;

    if (!newPassword) {
        return res.status(400).json({ message: "Nueva contraseña es requerida." });
    }

    try {
        const usersCollection = db.collection('users');
        // En producción: HASH la nueva contraseña aquí
        const result = await usersCollection.updateOne(
            { _id: new ObjectId(userId) },
            { $set: { password: newPassword } }
        );

        if (result.matchedCount === 0) {
            return res.status(404).json({ message: "Usuario no encontrado." });
        }
        res.status(200).json({ message: "Contraseña actualizada con éxito!" });
    } catch (error) {
        console.error("Error al actualizar contraseña:", error);
        res.status(500).json({ message: "Error interno del servidor al actualizar contraseña." });
    }
});

// 8. Obtener Historial de Reservas (todos los tipos)
app.get('/reservations/history/:userId', async (req, res) => {
    if (!db) return res.status(500).json({ message: "Base de datos no conectada." });
    const userId = req.params.userId;

    try {
        // Aquí puedes decidir si quieres que el historial sean todas las reservas asociadas a un userId,
        // o solo aquellas que ya "pasaron" o fueron "confirmadas".
        // Para este ejemplo, traeré todas las reservas del userId.
        const history = await db.collection('reservas').find({ userId }).toArray();
        res.status(200).json(history);
    } catch (error) {
        console.error("Error al obtener historial de reservas:", error);
        res.status(500).json({ message: "Error interno del servidor al obtener historial." });
    }
});


// Iniciar el servidor
app.listen(port, async () => {
    console.log(`Servidor backend corriendo en http://localhost:${port}`);
    await connectToMongo(); // Conectar a MongoDB cuando el servidor inicia
});