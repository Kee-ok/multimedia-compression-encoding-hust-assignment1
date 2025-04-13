CREATE MIDI FILE:


from mido import Message, MidiFile, MidiTrack  # Import classes and functions from the mido library to create and process MIDI files
import wave  # Import the standard wave library to process WAV files

def get_wav_duration(wav_file):
    """Returns the duration of a WAV file in seconds."""
    # This function calculates and returns the duration of a WAV file in seconds
    with wave.open(wav_file, 'rb') as wav:  # Open the WAV file in binary read mode
        frames = wav.getnframes()  # Get the total number of frames in the WAV file
        rate = wav.getframerate()  # Get the sample rate of the WAV file
        return frames / float(rate)  # Calculate the duration by dividing the number of frames by the sample rate

# === Configuration ===
wav_file = 'C:/Users/Admin/Documents/nén/recorded_audio.wav'  # Path to the input WAV file
output_midi = 'output.mid'  # Name of the output MIDI file
tempo = 500_000  # Tempo of the MIDI file in microseconds per beat (120 BPM)
ticks_per_beat = 480  # Number of ticks (MIDI time units) per beat
note_velocity = 64  # Velocity (volume) of the notes, ranging from 0 to 127

# === Get WAV duration ===
wav_duration = get_wav_duration(wav_file)  # Call the function to get the duration of the WAV file
print(f"Duration of '{wav_file}': {wav_duration:.2f} seconds")  # Print the duration of the WAV file to the console

# === Create MIDI structure ===
midi = MidiFile(ticks_per_beat=ticks_per_beat)  # Create a new MIDI file with 480 ticks per beat
track = MidiTrack()  # Create a new MIDI track
midi.tracks.append(track)  # Add the track to the MIDI file

# Set instrument to Vibraphone (program number 12)
track.append(Message('program_change', program=12, time=0))  # Set the instrument for the track to Vibraphone (program 12)

# === Define melody: (note_number, duration_in_ticks) ===
melody = [
    (60, 480),  # C4 (Middle C), lasting 480 ticks
    (64, 480),  # E4, lasting 480 ticks
    (67, 480),  # G4, lasting 480 ticks
    (72, 480),  # C5 (High C), lasting 480 ticks
    (71, 480),  # B4, lasting 480 ticks
    (69, 480),  # A4, lasting 480 ticks
    (65, 480),  # F4, lasting 480 ticks
    (62, 480),  # D4, lasting 480 ticks
]

# === Calculate total ticks needed to match WAV duration ===
# Calculate the total number of ticks needed to match the duration of the WAV file
total_ticks_target = int((wav_duration * 1_000_000 / tempo) * ticks_per_beat)

# === Generate melody to fill WAV duration ===
total_ticks = 0  # Counter for the total number of ticks added to the track
while total_ticks < total_ticks_target:  # Loop until the total ticks reach the target
    for note, duration in melody:  # Iterate through each note and its duration in the melody list
        if total_ticks + duration > total_ticks_target:  # If adding this note exceeds the target ticks
            duration = total_ticks_target - total_ticks  # Adjust the duration of the last note to fit exactly
        track.append(Message('note_on', note=note, velocity=note_velocity, time=0))  # Add a note_on event
        track.append(Message('note_off', note=note, velocity=note_velocity, time=duration))  # Add a note_off event
        total_ticks += duration  # Update the total ticks counter
        if total_ticks >= total_ticks_target:  # If the target ticks are reached, exit the loop
            break

# === Save MIDI file ===
midi.save(output_midi)  # Save the MIDI file to the specified path
print(f"MIDI file '{output_midi}' created successfully.")  # Print a success message
...............................................................................................................................................

MIX AUDIO WITH MIDI:

# -*- coding: utf-8 -*-
import os  # Import the os module to handle file paths and directories
import sys  # Import the sys module to configure system-level settings
from pydub import AudioSegment  # Import AudioSegment from pydub to process audio files
from pydub.effects import high_pass_filter  # Import high_pass_filter to apply audio effects
from midi2audio import FluidSynth  # Import FluidSynth to convert MIDI files to WAV format
from pydub.playback import play  # Import the play function to play audio files

# Configure the console output to use UTF-8 encoding for Unicode characters
sys.stdout.reconfigure(encoding='utf-8')

# ---------- Path Configuration ----------
# Define paths for input and output files
VOICE_WAV = r"C:/Users/Admin/Documents/nén/recorded_audio.wav"  # Path to the input voice WAV file
MIDI_FILE = r"C:/Users/Admin/Documents/nén/output.mid"  # Path to the MIDI backing track
SF2_PATH = r"C:/Users/Admin/Documents/nén/BassLong.sf2"  # Path to the pre-downloaded SoundFont file
OUTPUT_DIR = "output"  # Directory to store output files

# Create the output directory if it doesn't already exist
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ---------- Step 1: Convert MIDI to WAV ----------
def midi_to_wav(midi_path, output_wav, sf2_path):
    """
    Converts a MIDI file to a WAV file using FluidSynth and a SoundFont.
    """
    print("Converting MIDI to WAV...")  # Notify the user that the conversion is starting
    fs = FluidSynth(sf2_path)  # Initialize FluidSynth with the specified SoundFont
    fs.midi_to_audio(midi_path, output_wav)  # Convert the MIDI file to a WAV file
    print(f"✅ Saved backing track WAV: {output_wav}")  # Notify the user that the WAV file has been saved

# ---------- Step 2: Mix voice and music ----------
def mix_voice_and_music(voice_path, music_path, output_path, voice_volume=0, music_volume=-6):
    """
    Mixes a voice WAV file with a music WAV file.
    """
    print("🔄 Mixing voice and music...")  # Notify the user that the mixing process is starting
    voice = AudioSegment.from_file(voice_path)  # Load the voice WAV file
    music = AudioSegment.from_file(music_path)  # Load the music WAV file
    
    # Adjust the volume of the voice and music
    voice = voice + voice_volume  # Increase the volume of the voice
    music = music + music_volume  # Decrease the volume of the music
    
    # Trim or cut the music to match the length of the voice
    if len(music) > len(voice):  # If the music is longer than the voice
        music = music[:len(voice)]  # Cut the music to match the length of the voice
    elif len(voice) > len(music):  # If the voice is longer than the music
        voice = voice[:len(music)]  # Cut the voice to match the length of the music
    
    # Overlay the voice on top of the music
    mixed = voice.overlay(music)
    # Export the mixed audio to a WAV file
    mixed.export(output_path, format="wav")
    print(f"✅ Saved mixed file: {output_path}")  # Notify the user that the mixed file has been saved

# ---------- Step 3: Add Jazz Effects ----------
def add_jazz_effects(input_path, output_path):
    """
    Adds jazz effects to a WAV file.
    """
    print("🔄 Adding Jazz effects...")  # Notify the user that the jazz effects are being applied
    audio = AudioSegment.from_file(input_path)  # Load the input WAV file
    
    # Apply a high-pass filter to make the voice clearer
    audio = high_pass_filter(audio, cutoff=150)
    
    # Export the processed audio to a WAV file
    audio.export(output_path, format="wav")
    print(f"✅ Saved final file: {output_path}")  # Notify the user that the final file has been saved

# ---------- Run the entire process ----------
if __name__ == "__main__":
    # Step 1: Convert MIDI to WAV
    music_wav = os.path.join(OUTPUT_DIR, "output.wav")  # Define the path for the output WAV file
    midi_to_wav(MIDI_FILE, music_wav, SF2_PATH)  # Convert the MIDI file to a WAV file
    
    # Step 2: Mix voice and music
    mixed_wav = os.path.join(OUTPUT_DIR, "mixed.wav")  # Define the path for the mixed WAV file
    mix_voice_and_music(VOICE_WAV, music_wav, mixed_wav)  # Mix the voice and music WAV files
    
    # Step 3: Add effects
    final_wav = os.path.join(OUTPUT_DIR, "final_jazz_song.wav")  # Define the path for the final WAV file
    add_jazz_effects(mixed_wav, final_wav)  # Add jazz effects to the mixed WAV file
    
    # Optional: Play the final file
    print("🎵 Playing the final file...")  # Notify the user that the final file is being played
    play(AudioSegment.from_file(final_wav))  # Play the final WAV file
