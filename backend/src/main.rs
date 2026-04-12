use clap::{Args, Parser, Subcommand};
use serde::{Serialize};
use std::fs::File;
use std::io::{BufWriter, Write};
use hound;
use itertools::Itertools;

const WINDOW: usize = 2048;
const HOP: usize = 512;

#[derive(Parser)]
#[command(name = "CircleSiegeBackend")]
struct CLI {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    #[command(name = "analyze-wav")]
    AnalyzeWav(AnalyzeArgs),
}

#[derive(Args)]
struct AnalyzeArgs {
    #[arg(short, long)]
    input: String,

    #[arg(short, long)]
    output: String,
}


#[derive(Serialize)]
#[serde(tag = "type")]
enum Record {
    #[serde(rename = "meta")]
    Meta(MetaRecord),
    #[serde(rename = "energy")]
    Energy(EnergyRecord),
    #[serde(rename= "done")]
    Done,
}

#[derive(Serialize)]
struct MetaRecord {
    sr: u32,
    channels: u16,
    win: u32,
    hop: u32,
    duration: f64,
}

#[derive(Serialize)]
struct EnergyRecord {
    t: f64,
    e: f32
}

fn main() -> anyhow::Result<()> {
    let args = CLI::parse();
    match args.command {
        Commands::AnalyzeWav(params) => {
            let mut reader = hound::WavReader::open(&params.input).unwrap();
            let spec = reader.spec();

            let samples: Vec<f32> = reader
                .samples::<i16>()
                .chunks(spec.channels as usize)
                .into_iter()
                .map(|chunk| {
                    let mut sum: f32 = 0.0;
                    let mut count: f32 = 0.0;
                    for s in chunk {
                        if let Ok(sample) = s {
                            sum += sample as f32;
                            count += 1.0
                        }
                    }
                    (sum / count) / 37268.0
                })
                .collect();

            let mut energy: Vec<Record> = Vec::new();

            let mut rms_max: f32 = 1e-6;
            let mut e_smooth: f32 = 0f32;

            let mut i = 0;
            while (HOP * i) + WINDOW < samples.len() {
                let start = i * HOP;
                let t = start as f64 / spec.sample_rate as f64;

                let rms = (samples[start..start+WINDOW].iter().map(|&x: &f32| x * x).sum::<f32>() / WINDOW as f32).sqrt();
                rms_max = rms.max(rms_max * 0.9995);

                let e_raw = (rms / (rms_max + 1e-6)).clamp(0.0, 1.0);
                e_smooth = e_smooth * 0.8 + e_raw * 0.2;

                // downsampling to prevent flooding buffer
                if i % 2 == 0 {
                    energy.push(Record::Energy(EnergyRecord { t, e: e_smooth }));
                }

                i += 1;
            }

            let file = File::create(&params.output)?;
            let mut w = BufWriter::new(file);

            let meta = Record::Meta(MetaRecord {
                sr: spec.sample_rate,
                channels: spec.channels,
                win: WINDOW as u32,
                hop: HOP as u32,
                duration: (reader.len() / spec.channels as u32) as f64 / spec.sample_rate as f64,
            });

            serde_json::to_writer(&mut w, &meta)?;
            w.write_all(b"\n")?;

            serde_json::to_writer(&mut w, &energy)?;
            w.write_all(b"\n")?;

            serde_json::to_writer(&mut w, &Record::Done)?;
            w.write_all(b"\n")?;
        },
    }

    Ok(())
}
