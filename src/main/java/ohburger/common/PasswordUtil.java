package ohburger.common;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 * 비밀번호 해시 (M-01, M-02).
 * 회원마다 무작위 솔트를 만들고 SHA-256(솔트 + 비밀번호) 를 16진수로 저장한다.
 */
public final class PasswordUtil {

    private static final SecureRandom RANDOM = new SecureRandom();
    private static final char[] HEX = "0123456789abcdef".toCharArray();

    private PasswordUtil() {
    }

    /** 새 솔트를 만든다. 16바이트를 16진수 32자로 돌려준다 (member.salt 는 CHAR(32)). */
    public static String newSalt() {
        byte[] bytes = new byte[16];
        RANDOM.nextBytes(bytes);
        return toHex(bytes);
    }

    /** SHA-256(솔트 + 비밀번호) 를 16진수 64자로 돌려준다 (member.password_hash 는 CHAR(64)). */
    public static String hash(String salt, String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            return toHex(md.digest((salt + password).getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException("SHA-256 을 쓸 수 없습니다", e);
        }
    }

    /** 입력한 비밀번호가 저장된 해시와 맞는지 본다. 비교 시간으로 값이 새지 않게 isEqual 을 쓴다. */
    public static boolean matches(String salt, String password, String expectedHash) {
        return MessageDigest.isEqual(
                hash(salt, password).getBytes(StandardCharsets.US_ASCII),
                expectedHash.getBytes(StandardCharsets.US_ASCII));
    }

    private static String toHex(byte[] bytes) {
        char[] out = new char[bytes.length * 2];
        for (int i = 0; i < bytes.length; i++) {
            out[i * 2] = HEX[(bytes[i] >> 4) & 0x0f];
            out[i * 2 + 1] = HEX[bytes[i] & 0x0f];
        }
        return new String(out);
    }
}
