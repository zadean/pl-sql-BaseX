package com.zadean.oracle.basex;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Blob;
import java.sql.Clob;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * <p>
 * Java <a href="http://basex.org/">BaseX</a> client for use in the Oracle JVM.
 * Roughly based on BaseXClient in the BaseX <a href=
 * "https://github.com/BaseXdb/basex/tree/master/basex-examples/src/main/java/org/basex/examples/api">
 * repository</a>.
 * </p>
 * <p>
 * The static implementation is a 'must' for the JVM. The single class imports
 * are to keep down the footprint in the database. LOB's should be initialized
 * in the DB before they are used; otherwise NullPointerException. Currently
 * (11.2), the Oracle JVM uses the Java 1.6 standard libraries.
 * </p>
 * 
 * @author Zachary N. Dean <contact[at]zadean[dot]com>
 */
public class BaseXClient {

	/** The encoding for all character streams. */
	private static final String UTF8 = "UTF-8";

	/** The socket being used by all calls. */
	private static Socket socket;
	/** Output stream. */
	private static OutputStream socketOutputStream;
	/** Input stream (buffered). */
	private static BufferedInputStream socketInputStream;

	/** Info string */
	private static String info;
	/** Query result cache */
	private static HashMap<String, ArrayList<byte[]>> cache = new HashMap<String, ArrayList<byte[]>>();
	/** Query current position cache */
	private static HashMap<String, Integer> cachePos = new HashMap<String, Integer>();

	// commands
	private static final char CMD_QUERY = 0;
	private static final char CMD_CREATE = 8;
	private static final char CMD_ADD = 9;
	private static final char CMD_REPLACE = 12;
	private static final char CMD_STORE = 13;
	// query commands
	private static final char QRY_CLOSE = 2;
	private static final char QRY_BIND = 3;
	private static final char QRY_RESULTS = 4;
	private static final char QRY_EXEC = 5;
	private static final char QRY_INFO = 6;
	private static final char QRY_OPTIONS = 7;
	private static final char QRY_CONTEXT = 14;

	// private static final char QRY_UPDATING = 30;
	// private static final char QRY_FULL = 31;

	/**
	 * Creates a client session with the given credentials. If there is already
	 * an open session, it will be closed and a new session created.
	 * 
	 * @param host
	 *            Host
	 * @param port
	 *            Port
	 * @param username
	 *            User
	 * @param password
	 *            Password
	 * @throws IOException
	 *             Access denied, no server
	 */
	public static void open(final String host, final int port, final String username, final String password)
			throws IOException {
		// close any open socket
		if (!isClosed()) {
			close();
		}
		socket = new Socket();
		socket.connect(new InetSocketAddress(host, port), 5000);
		socketInputStream = new BufferedInputStream(socket.getInputStream());
		socketOutputStream = socket.getOutputStream();

		// receive server response
		final String[] response = readLine().split(":");
		final String code, nonce;
		if (response.length > 1) {
			// support for digest authentication
			code = username + ':' + response[0] + ':' + password;
			nonce = response[1];
		} else {
			// support for cram-md5 (Version < 8.0)
			code = password;
			nonce = response[0];
		}

		writeLine(username);
		writeLine(md5(md5(code) + nonce));

		// receive success flag
		if (!ok())
			throw new IOException("Access denied.");
	}

	/**
	 * Closes an open session. Attempts to neatly close the session on the
	 * server, closes the socket and frees static variables to avoid resource
	 * leaks.
	 */
	public static void close() {
		try {
			writeLine("exit");
		} catch (Exception e) {
			e.printStackTrace();
		}
		try {
			socket.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		socket = null;
		socketInputStream = null;
		socketOutputStream = null;
	}

	/**
	 * Executes a command and returns the result. Sets the
	 * {@link BaseXClient#info()} value.
	 * 
	 * @param command
	 *            The command to execute.
	 * @param output
	 *            The results of the command.
	 * @throws IOException
	 * @throws SQLException
	 */
	public static void execute(final String command, Clob output) throws IOException, SQLException {
		check();
		// just in case the LOB has been reused
		output.truncate(0);
		writeLine(command);
		readLine(output.setAsciiStream(1));
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Returns the information string for the last command run that sets it.
	 * 
	 * @return The info string.
	 */
	public static String info() {
		return info;
	}

	/**
	 * Creates a database. Sets the {@link BaseXClient#info()} value.
	 * 
	 * @param name
	 *            Database name.
	 * @param input
	 *            XML input to initialize the database.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void create(final String name, Clob input) throws IOException, SQLException {
		check();
		write(CMD_CREATE);
		writeLine(name);
		write(input.getAsciiStream());
		writeLine();
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Adds a document to the currently open database. Sets the
	 * {@link BaseXClient#info()} value.
	 * 
	 * @param path
	 *            Path of the document to add.
	 * @param input
	 *            The document to add.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void add(final String path, Clob input) throws IOException, SQLException {
		check();
		write(CMD_ADD);
		writeLine(path);
		write(input.getAsciiStream());
		writeLine();
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Replaces a document to the currently open database. Sets the
	 * {@link BaseXClient#info()} value.
	 * 
	 * @param path
	 *            Path to replace.
	 * @param input
	 *            Input to replace with.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void replace(final String path, Clob input) throws IOException, SQLException {
		check();
		write(CMD_REPLACE);
		writeLine(path);
		write(input.getAsciiStream());
		writeLine();
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Stores a binary resource in the currently open database. Sets the
	 * {@link BaseXClient#info()} value.
	 * 
	 * @param path
	 *            Path to resource.
	 * @param input
	 *            Raw binary input.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void store(final String path, Blob input) throws IOException, SQLException {
		check();
		write(CMD_STORE);
		writeLine(path);
		writeBinary(input.getBinaryStream());
		writeLine();
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Retrieves a binary resource from the currently open database. Sets the
	 * {@link BaseXClient#info()} value.
	 * 
	 * @param path
	 *            Path to resource.
	 * @param output
	 *            Raw binary output.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void retrieve(final String path, Blob output) throws IOException, SQLException {
		check();
		// just in case the LOB has been reused
		output.truncate(0);
		writeLine("retrieve " + path);
		readBinary(output.setBinaryStream(1));
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Deletes all documents from the currently opened database that start with
	 * the specified path. Sets the {@link BaseXClient#info()} value.
	 * 
	 * @param path
	 *            Path to delete.
	 * @param output
	 *            Output,
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void delete(final String path, Clob output) throws IOException, SQLException {
		check();
		// just in case the LOB has been reused
		output.truncate(0);
		writeLine("delete " + path);
		readLine(output.setAsciiStream(1));
		info = readLine();
		if (!ok())
			throw new IOException(info);
	}

	/**
	 * Registers a query and returns the query id.
	 * 
	 * @param query
	 *            The query text.
	 * @return The query ID.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static String query(Clob query) throws IOException, SQLException {
		check();
		write(CMD_QUERY);
		write(query.getAsciiStream());
		writeLine();
		final String queryId = readLine();
		if (!ok())
			throw new IOException(readLine());
		// only init if ok
		initQuery(queryId);
		return queryId;
	}

	/**
	 * Checks for more items in the result cache. Fills the cache if empty.
	 * 
	 * @param queryId
	 *            The query ID to check.
	 * @return true if more.
	 * @throws IOException
	 *             Communication problem.
	 */
	public static boolean more(String queryId) throws IOException {
		if (cache.get(queryId) == null) {
			write(QRY_RESULTS);
			writeLine(queryId);
			ArrayList<byte[]> results = new ArrayList<byte[]>();
			final ByteArrayOutputStream os = new ByteArrayOutputStream();
			// this loop reads the first byte and throws it away.
			// the byte is the Type of the item being returned.
			// The list of types is at org.basex.query.value.type.Type
			while (socketInputStream.read() > 0) {
				readLine(os);
				results.add(os.toByteArray());
				os.reset();
			}
			if (!ok())
				throw new IOException(readLine());
			cache.put(queryId, results);
		}
		if (cachePos.get(queryId) < cache.get(queryId).size())
			return true;
		cache.put(queryId, null);
		return false;
	}

	/**
	 * Gets the next item in the result cache.
	 * 
	 * @param queryId
	 *            The query ID to get the next result from.
	 * @param output
	 *            The next result.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void next(String queryId, Clob output) throws IOException, SQLException {
		// just in case the LOB has been reused
		output.truncate(0);
		if (more(queryId)) {
			int pos = cachePos.get(queryId);
			byte[] cacheRes = cache.get(queryId).set(pos, null);
			BufferedOutputStream ins = new BufferedOutputStream(output.setAsciiStream(1));
			for (int i = 0; i < cacheRes.length; i++) {
				ins.write(cacheRes[i]);
			}
			ins.flush();
			cachePos.put(queryId, ++pos);
		}
	}

	/**
	 * Executes this query and returns the entire result.
	 * 
	 * @param queryId
	 *            Query ID to execute.
	 * @param output
	 *            The query results.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void results(final String queryId, final Clob output) throws IOException, SQLException {
		getClobResults(QRY_EXEC, queryId, output);
	}

	/**
	 * Returns query info.
	 * 
	 * @param queryId
	 *            The query ID.
	 * @return Information about this query.
	 * @throws IOException
	 *             Communication problem.
	 */
	public static String info(final String queryId) throws IOException {
		socketOutputStream.write(QRY_INFO);
		writeLine(queryId);
		String s = readLine();
		if (!ok())
			throw new IOException(readLine());
		return s;
	}

	/**
	 * Returns serialization parameters.
	 * 
	 * @param queryId
	 *            The query ID.
	 * @param output
	 *            The serialization parameters.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void options(final String queryId, final Clob output) throws IOException, SQLException {
		getClobResults(QRY_OPTIONS, queryId, output);
	}

	/**
	 * Binds a value to an external variable. Sets the
	 * {@link BaseXClient#info()}
	 * 
	 * @param queryId
	 *            The query ID.
	 * @param name
	 *            Name of the external variable.
	 * @param value
	 *            The value to bind.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void bind(final String queryId, final String name, final Clob value)
			throws IOException, SQLException {
		bind(queryId, name, value, "");
	}

	/**
	 * Binds a value to an external variable. Sets the
	 * {@link BaseXClient#info()}
	 * 
	 * @param queryId
	 *            The query ID.
	 * @param name
	 *            Name of the external variable.
	 * @param value
	 *            The value to bind.
	 * @param type
	 *            The type of the variable.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void bind(final String queryId, final String name, final Clob value, final String type)
			throws IOException, SQLException {
		write(QRY_BIND);
		writeLine(queryId);
		writeLine(name);
		write(value.getAsciiStream());
		writeLine();
		writeLine(type);
		info = readLine();
		if (!ok())
			throw new IOException(readLine());
	}

	/**
	 * Binds a value to the context item. Sets the {@link BaseXClient#info()}
	 * value.
	 * 
	 * @param queryId
	 *            The query ID.
	 * @param value
	 *            The value to bind.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void context(final String queryId, final Clob value) throws IOException, SQLException {
		context(queryId, value, "");
	}

	/**
	 * Binds a value to the context item. Sets the {@link BaseXClient#info()}
	 * value.
	 * 
	 * @param queryId
	 *            The query ID.
	 * @param value
	 *            The value to bind.
	 * @param type
	 *            The type of the bound context.
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	public static void context(final String queryId, final Clob value, final String type)
			throws IOException, SQLException {
		write(QRY_CONTEXT);
		writeLine(queryId);
		write(value.getAsciiStream());
		writeLine();
		writeLine(type);
		info = readLine();
		if (!ok())
			throw new IOException(readLine());
	}

	/**
	 * Releases the query in the server. Sets the {@link BaseXClient#info()}
	 * value.
	 * 
	 * @param queryId
	 *            The query ID.
	 * @throws IOException
	 *             Communication problem.
	 */
	public static void close(final String queryId) throws IOException {
		write(QRY_CLOSE);
		writeLine(queryId);
		info = readLine();
		destroyQuery(queryId);
		if (!ok())
			throw new IOException(readLine());
	}

	/**
	 * Helper for simple code + queryId requests.
	 * 
	 * @param code
	 * @param queryId
	 * @param output
	 * @throws IOException
	 *             Communication problem.
	 * @throws SQLException
	 *             LOB problem
	 */
	private static void getClobResults(final int code, final String queryId, final Clob output)
			throws IOException, SQLException {
		// just in case the LOB has been reused
		output.truncate(0);
		socketOutputStream.write(code);
		writeLine(queryId);
		readLine(output.setAsciiStream(1));
		if (!ok())
			throw new IOException(readLine());
	}

	/**
	 * Setup the query result cache for this query.
	 * 
	 * @param queryId
	 */
	private static void initQuery(String queryId) {
		cache.put(queryId, null);
		cachePos.put(queryId, 0);
	}

	/**
	 * Tear down the query result cache for this query.
	 * 
	 * @param queryId
	 */
	private static void destroyQuery(String queryId) {
		cache.remove(queryId);
		cachePos.remove(queryId);
	}

	/**
	 * Checks the next success flag.
	 * 
	 * @return value of check
	 * @throws IOException
	 *             Exception
	 */
	private static boolean ok() throws IOException {
		socketOutputStream.flush();
		int got = socketInputStream.read();
		return got == 0;
	}

	/**
	 * Sends terminator.
	 * 
	 * @throws IOException
	 */
	private static void writeLine() throws IOException {
		socketOutputStream.write('\0');
	}

	/**
	 * Sends string plus terminator.
	 * 
	 * @param string
	 * @throws IOException
	 */
	private static void writeLine(final String string) throws IOException {
		socketOutputStream.write((string + '\0').getBytes(UTF8));
	}

	/**
	 * Sends single byte.
	 * 
	 * @param cmd
	 * @throws IOException
	 */
	private static void write(final char cmd) throws IOException {
		socketOutputStream.write(cmd);
	}

	/**
	 * Writes text input stream without terminator.
	 * 
	 * @param input
	 * @throws IOException
	 */
	private static void write(final InputStream input) throws IOException {
		final BufferedInputStream bis = new BufferedInputStream(input);
		final BufferedOutputStream bos = new BufferedOutputStream(socketOutputStream);
		final Writer out = new OutputStreamWriter(bos, UTF8);
		for (int b; (b = bis.read()) != -1;) {
			// 0x00 and 0xFF will be prefixed by 0xFF
			if (b == 0x00 || b == 0xFF)
				out.write(0xFF);
			out.write(b);
		}
		out.flush();
	}

	/**
	 * Writes binary input stream without terminator.
	 * 
	 * @param input
	 * @throws IOException
	 */
	private static void writeBinary(final InputStream input) throws IOException {
		final BufferedInputStream bis = new BufferedInputStream(input);
		final BufferedOutputStream bos = new BufferedOutputStream(socketOutputStream);
		for (int b; (b = bis.read()) != -1;) {
			// 0x00 and 0xFF will be prefixed by 0xFF
			if (b == 0x00 || b == 0xFF)
				bos.write(0xFF);
			bos.write(b);
		}
		bos.flush();
	}

	/**
	 * Reads text input until terminator when known to be shorter than 4000
	 * characters.
	 * 
	 * @return
	 * @throws IOException
	 */
	private static String readLine() throws IOException {
		final ByteArrayOutputStream os = new ByteArrayOutputStream();
		readLine(os);
		return new String(os.toByteArray(), UTF8);
	}

	/**
	 * Reads text input until terminator onto output stream.
	 * 
	 * @param output
	 * @throws IOException
	 */
	private static void readLine(final OutputStream output) throws IOException {
		final Writer out = new OutputStreamWriter(output, UTF8);
		for (int b; (b = socketInputStream.read()) > 0;) {
			// read next byte if 0xFF is received
			out.write(b == 0xFF ? socketInputStream.read() : b);
		}
		out.flush();
	}

	/**
	 * Reads binary input until terminator onto output stream.
	 * 
	 * @param output
	 * @throws IOException
	 */
	private static void readBinary(final OutputStream output) throws IOException {
		for (int b; (b = socketInputStream.read()) > 0;) {
			// read next byte if 0xFF is received
			output.write(b == 0xFF ? socketInputStream.read() : b);
		}
		output.flush();
	}

	/**
	 * Returns an MD5 hash.
	 * 
	 * @param str
	 *            String
	 * @return String
	 */
	private static String md5(final String str) {
		final StringBuilder sb = new StringBuilder();
		try {
			final MessageDigest md = MessageDigest.getInstance("MD5");
			md.update(str.getBytes());
			byte[] ba = md.digest();
			for (int i = 0; i < ba.length; i++) {
				final byte b = ba[i];
				final String s = Integer.toHexString(b & 0xFF);
				if (s.length() == 1)
					sb.append('0');
				sb.append(s);
			}
		} catch (final NoSuchAlgorithmException ex) {
			// should not occur
			ex.printStackTrace();
		}
		return sb.toString();
	}

	/**
	 * @return if the socket is closed.
	 */
	private static boolean isClosed() {
		if (socket == null)
			return true;
		return socket.isClosed();
	}

	/**
	 * Checks if the socket can be used.
	 * 
	 * @throws IOException
	 */
	private static void check() throws IOException {
		if (isClosed())
			throw new IOException("Socket closed.");
	}
}
