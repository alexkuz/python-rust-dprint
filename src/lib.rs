use std::path::PathBuf;
use serde_json;
use serde_json::Value;
use pyo3::prelude::*;
use dprint_plugin_typescript::format_text as dprint_format_text;
use dprint_plugin_typescript::configuration::Configuration;
use dprint_plugin_typescript::configuration::ConfigurationBuilder;

fn merge(a: &mut Value, b: &Value) {
    match (a, b) {
        (&mut Value::Object(ref mut a), &Value::Object(ref b)) => {
            for (k, v) in b {
                merge(a.entry(k.clone()).or_insert(Value::Null), v);
            }
        }
        (a, b) => {
            *a = b.clone();
        }
    }
}

#[pyfunction]
fn format_text(filename: &str, code: &str, options: &str) -> PyResult<String> {
  let file_path_str = PathBuf::from(filename);
  let mut config_json: Value = serde_json::to_value(ConfigurationBuilder::new().build()).unwrap();
  let options_json: Value = serde_json::from_str(&options).unwrap();
  merge(&mut config_json, &options_json);
  let config: Configuration = serde_json::from_value(config_json).unwrap();

  match dprint_format_text(&file_path_str, &code, &config) {
    Ok(opt) => {
      match opt {
        Some(formatted_text) => {
          if formatted_text != code {
            Ok(formatted_text)
          } else {
            Ok(code.to_string())
          }
        }
        None => {
          Ok(code.to_string())
        }
      }
    }
    Err(e) => {
      eprintln!("{}", e);
      Ok(code.to_string())
    }
  }
}

/// A Python module implemented in Rust. The name of this function must match
/// the `lib.name` setting in the `Cargo.toml`, else Python will not be able to
/// import the module.
#[pymodule]
fn dprint_python_bridge(_py: Python, m: &PyModule) -> PyResult<()> {
  m.add_function(wrap_pyfunction!(format_text, m)?)?;

  Ok(())
}
