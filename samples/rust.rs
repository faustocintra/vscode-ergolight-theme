use std::{collections::HashMap, fmt::Display};

const VERSION: &str = "1.0.0";

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum OrderStatus<'a> {
    Draft,
    Paid { reference: &'a str },
    Shipped,
}

pub trait Auditable {
    fn audit(&self) -> String;
}

pub struct Order<'a, T>
where
    T: Display + Clone,
{
    pub id: u64,
    pub status: OrderStatus<'a>,
    pub payload: Option<T>,
}

impl<'a, T: Display + Clone> Auditable for Order<'a, T> {
    fn audit(&self) -> String {
        let mut meta: HashMap<&str, String> = HashMap::new();
        meta.insert("version", VERSION.into());
        format!("order={} payload={:?} meta={:?}", self.id, self.payload.clone().map(|v| v.to_string()), meta)
    }
}

fn main() {
    let order = Order { id: 42, status: OrderStatus::Paid { reference: "BRL-42" }, payload: Some("label") };
    println!("{}", order.audit());
}

