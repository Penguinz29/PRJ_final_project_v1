package com.edututor.util;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import org.junit.jupiter.api.Test;

class DocumentValidatorTest {

    private static byte[] zip(String entryName, String content) throws IOException {
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (ZipOutputStream z = new ZipOutputStream(bos)) {
            z.putNextEntry(new ZipEntry(entryName));
            z.write(content.getBytes(StandardCharsets.UTF_8));
            z.closeEntry();
        }
        return bos.toByteArray();
    }

    @Test
    void readsTextFromDocx() throws IOException {
        String xml = "<w:document><w:body><w:p><w:r><w:t>Tính $x^2$ &amp; $y$</w:t></w:r></w:p>"
                + "<w:p><w:r><w:t xml:space=\"preserve\">Câu 2</w:t></w:r></w:p></w:body></w:document>";
        DocumentValidator.Info info = DocumentValidator.validate(zip("word/document.xml", xml));
        assertEquals(DocumentValidator.Kind.DOCX, info.kind());
        assertEquals("docx", info.extension());
        assertEquals("Tính $x^2$ & $y$\nCâu 2", info.text());
    }

    @Test
    void acceptsPdfByMagicBytes() {
        byte[] pdf = "%PDF-1.7\n...".getBytes(StandardCharsets.US_ASCII);
        DocumentValidator.Info info = DocumentValidator.validate(pdf);
        assertEquals(DocumentValidator.Kind.PDF, info.kind());
        assertEquals("application/pdf", info.mimeType());
    }

    @Test
    void rejectsZipThatIsNotWord() throws IOException {
        assertThrows(IllegalArgumentException.class,
                () -> DocumentValidator.validate(zip("xl/workbook.xml", "<x/>")));
    }

    @Test
    void rejectsLegacyDocAndUnknownFiles() {
        byte[] ole = {(byte) 0xD0, (byte) 0xCF, 0x11, (byte) 0xE0, (byte) 0xA1, (byte) 0xB1, 0x1A, (byte) 0xE1, 0, 0};
        IllegalArgumentException e = assertThrows(IllegalArgumentException.class, () -> DocumentValidator.validate(ole));
        assertTrue(e.getMessage().contains(".docx"));
        assertThrows(IllegalArgumentException.class,
                () -> DocumentValidator.validate("hello world".getBytes(StandardCharsets.UTF_8)));
        assertThrows(IllegalArgumentException.class, () -> DocumentValidator.validate(new byte[0]));
    }
}
