use clap::{Args, Parser, Subcommand};
use serde::{Serialize};
use std::fs::File;
use std::io::{BufWriter, Write};

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
    #[serde(rename= "done")]
    Done,
}

#[derive(Serialize)]
struct MetaRecord {
    sr: u32,
    channels: u16,
    win: u32,
    hop: u32,
    duration: f32,
}

fn main() -> anyhow::Result<()> {
    let args = CLI::parse();
    match args.command {
        Commands::AnalyzeWav(params) => {
            let file = File::create(&params.output)?;
            let mut w = BufWriter::new(file);

            let meta = Record::Meta(MetaRecord {
                sr: 0,
                channels: 0,
                win: 2048,
                hop: 512,
                duration: 0.0,
            });

            serde_json::to_writer(&mut w, &meta)?;
            w.write_all(b"\n")?;

            serde_json::to_writer(&mut w, &Record::Done)?;
            w.write_all(b"\n")?;
        },
    }

    Ok(())
}
