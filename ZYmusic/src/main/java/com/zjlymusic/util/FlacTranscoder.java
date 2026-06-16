package com.zjlymusic.util;

import org.jflac.sound.spi.FlacAudioFileReader;
import org.jflac.sound.spi.FlacFormatConversionProvider;

import javax.sound.sampled.*;
import java.io.*;

public final class FlacTranscoder {
    private static final int WAV_HEADER_SIZE = 44;

    private FlacTranscoder() {}

    // Calculate WAV size from FLAC metadata (without decoding)
    public static long getWavSize(File flacFile) throws Exception {
        FlacAudioFileReader reader = new FlacAudioFileReader();
        AudioFileFormat fileFormat = reader.getAudioFileFormat(flacFile);
        AudioFormat flacFormat = fileFormat.getFormat();
        int channels = flacFormat.getChannels();
        int blockAlign = channels * (16 / 8);
        long totalFrames = fileFormat.getFrameLength();
        if (totalFrames > 0 && totalFrames != AudioSystem.NOT_SPECIFIED) {
            return 44 + totalFrames * blockAlign; // 44-byte WAV header + PCM data
        }
        return -1; // unknown size
    }

    // Stream transcode: write WAV header + PCM data directly to output stream
    // Browser starts playing immediately
    public static void streamTranscodeToWav(File flacFile, OutputStream out) throws Exception {
        FlacAudioFileReader reader = new FlacAudioFileReader();
        AudioInputStream flacStream = reader.getAudioInputStream(flacFile);
        AudioFormat flacFormat = flacStream.getFormat();

        int sampleRate = (int) flacFormat.getSampleRate();
        int channels = flacFormat.getChannels();
        int bitsPerSample = 16;
        int blockAlign = channels * (bitsPerSample / 8);
        int byteRate = sampleRate * blockAlign;

        // Get total samples from StreamInfo for WAV header
        AudioFileFormat fileFormat = reader.getAudioFileFormat(flacFile);
        long totalFrames = fileFormat.getFrameLength();
        long totalSamples = (totalFrames > 0 && totalFrames != AudioSystem.NOT_SPECIFIED)
            ? totalFrames : 0;
        long dataSize = totalSamples * blockAlign;

        // Write WAV header
        writeWavHeader(out, sampleRate, channels, bitsPerSample, dataSize);

        // Stream-decode FLAC -> PCM -> output
        AudioFormat pcmFormat = new AudioFormat(
            AudioFormat.Encoding.PCM_SIGNED,
            sampleRate, bitsPerSample, channels, blockAlign, sampleRate, false
        );

        FlacFormatConversionProvider converter = new FlacFormatConversionProvider();
        AudioInputStream pcmStream = converter.getAudioInputStream(pcmFormat, flacStream);

        byte[] buffer = new byte[65536];
        int bytesRead;
        long totalWritten = 0;
        while ((bytesRead = pcmStream.read(buffer)) != -1) {
            out.write(buffer, 0, bytesRead);
            totalWritten += bytesRead;
        }
        pcmStream.close();
        flacStream.close();

        // Fix WAV header if dataSize was unknown (0)
        if (dataSize == 0 || totalFrames <= 0) {
            // Can't easily fix header in streaming mode, but browsers handle this
            out.flush();
        }
        out.flush();
    }

    // Full transcode to byte array with correct WAV headers (seekable)
    public static byte[] transcodeToWav(File flacFile) throws Exception {
        FlacAudioFileReader reader = new FlacAudioFileReader();
        AudioInputStream flacStream = reader.getAudioInputStream(flacFile);
        AudioFormat flacFormat = flacStream.getFormat();

        int sampleRate = (int) flacFormat.getSampleRate();
        int channels = flacFormat.getChannels();
        int bitsPerSample = 16;
        int blockAlign = channels * (bitsPerSample / 8);

        AudioFormat pcmFormat = new AudioFormat(
            AudioFormat.Encoding.PCM_SIGNED,
            sampleRate, bitsPerSample, channels, blockAlign, sampleRate, false
        );

        FlacFormatConversionProvider converter = new FlacFormatConversionProvider();
        AudioInputStream pcmStream = converter.getAudioInputStream(pcmFormat, flacStream);

        // Decode all PCM data first to compute correct size
        ByteArrayOutputStream pcmBuf = new ByteArrayOutputStream();
        byte[] buffer = new byte[65536];
        int bytesRead;
        while ((bytesRead = pcmStream.read(buffer)) != -1) {
            pcmBuf.write(buffer, 0, bytesRead);
        }
        pcmStream.close();
        flacStream.close();

        byte[] pcmData = pcmBuf.toByteArray();

        // Build WAV with correct data chunk size
        int byteRate = sampleRate * blockAlign;
        long dataSize = pcmData.length;
        long fileSize = 36 + dataSize;

        ByteArrayOutputStream wav = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(wav);

        // RIFF header
        dos.writeBytes("RIFF");
        writeIntLE(dos, (int) (fileSize & 0xFFFFFFFFL));
        dos.writeBytes("WAVE");

        // fmt chunk
        dos.writeBytes("fmt ");
        writeIntLE(dos, 16);
        writeShortLE(dos, (short) 1);
        writeShortLE(dos, (short) channels);
        writeIntLE(dos, sampleRate);
        writeIntLE(dos, byteRate);
        writeShortLE(dos, (short) blockAlign);
        writeShortLE(dos, (short) bitsPerSample);

        // data chunk with correct size
        dos.writeBytes("data");
        writeIntLE(dos, (int) (dataSize & 0xFFFFFFFFL));

        dos.flush();
        wav.write(pcmData);

        return wav.toByteArray();
    }

    // Extract duration in seconds from audio metadata
    public static int getDurationSeconds(File audioFile) {
        try {
            if (isFlacFile(audioFile.getName())) {
                FlacAudioFileReader reader = new FlacAudioFileReader();
                AudioFileFormat fmt = reader.getAudioFileFormat(audioFile);
                long frames = fmt.getFrameLength();
                float rate = fmt.getFormat().getSampleRate();
                if (frames > 0 && frames != AudioSystem.NOT_SPECIFIED && rate > 0) {
                    return (int) (frames / rate);
                }
            } else {
                AudioFileFormat fmt = AudioSystem.getAudioFileFormat(audioFile);
                long frames = fmt.getFrameLength();
                float rate = fmt.getFormat().getSampleRate();
                if (frames > 0 && frames != AudioSystem.NOT_SPECIFIED && rate > 0) {
                    return (int) (frames / rate);
                }
            }
        } catch (Exception e) {
            // Duration will be determined by browser
        }
        return 0;
    }

    private static void writeWavHeader(OutputStream out, int sampleRate, int channels, int bitsPerSample, long dataSize) throws IOException {
        int blockAlign = channels * (bitsPerSample / 8);
        int byteRate = sampleRate * blockAlign;
        long fileSize = 36 + dataSize;

        ByteArrayOutputStream header = new ByteArrayOutputStream(44);
        DataOutputStream dos = new DataOutputStream(header);

        // RIFF header
        dos.writeBytes("RIFF");
        writeIntLE(dos, (int) (fileSize & 0xFFFFFFFFL));
        dos.writeBytes("WAVE");

        // fmt chunk
        dos.writeBytes("fmt ");
        writeIntLE(dos, 16);          // chunk size
        writeShortLE(dos, (short) 1);  // PCM format
        writeShortLE(dos, (short) channels);
        writeIntLE(dos, sampleRate);
        writeIntLE(dos, byteRate);
        writeShortLE(dos, (short) blockAlign);
        writeShortLE(dos, (short) bitsPerSample);

        // data chunk
        dos.writeBytes("data");
        writeIntLE(dos, (int) (dataSize & 0xFFFFFFFFL));

        dos.flush();
        out.write(header.toByteArray());
    }

    private static void writeIntLE(DataOutputStream dos, int value) throws IOException {
        dos.writeByte(value & 0xFF);
        dos.writeByte((value >> 8) & 0xFF);
        dos.writeByte((value >> 16) & 0xFF);
        dos.writeByte((value >> 24) & 0xFF);
    }

    private static void writeShortLE(DataOutputStream dos, short value) throws IOException {
        dos.writeByte(value & 0xFF);
        dos.writeByte((value >> 8) & 0xFF);
    }

    public static boolean isFlacFile(String path) {
        return path != null && path.toLowerCase().endsWith(".flac");
    }

    public static boolean isDesktopClient(String userAgent) {
        return userAgent != null && userAgent.contains("ZYMusicDesktop");
    }

    public static File getCachedWavFile(File flacFile) {
        File cacheDir = new File(AppPaths.getUploadsDir(), ".transcode_cache");
        if (!cacheDir.exists()) {
            cacheDir.mkdirs();
        }
        String cacheName = flacFile.getName() + "_" + flacFile.lastModified() + ".wav";
        return new File(cacheDir, cacheName);
    }

    public static void cacheWav(File flacFile, byte[] wavBytes) throws IOException {
        File cachedWav = getCachedWavFile(flacFile);
        java.nio.file.Files.write(cachedWav.toPath(), wavBytes);
    }
}
